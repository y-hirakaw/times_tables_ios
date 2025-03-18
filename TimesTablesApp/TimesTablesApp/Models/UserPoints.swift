import Foundation
import SwiftData

/// ユーザーのポイント情報を管理するモデル
@Model
final class UserPoints {
    /// 合計獲得ポイント（累積、減少しない）
    var totalEarnedPoints: Int
    /// 現在使用可能なポイント（消費すると減少する）
    var availablePoints: Int
    /// 最終更新日時
    var lastUpdated: Date
    
    /// 苦手問題ボーナスデータ（JSON形式で保存）
    var difficultQuestionBonus_Data: Data?
    
    /// 苦手問題に対するボーナス履歴を追跡
    /// キーは問題の識別子、値は該当問題で過去に獲得したボーナスポイントの合計
    var difficultQuestionBonuses: [String: Int] {
        get {
            guard let data = difficultQuestionBonus_Data else { return [:] }
            return (try? JSONDecoder().decode([String: Int].self, from: data)) ?? [:]
        }
        set {
            difficultQuestionBonus_Data = try? JSONEncoder().encode(newValue)
        }
    }
    
    init(totalEarnedPoints: Int = 0, availablePoints: Int = 0) {
        self.totalEarnedPoints = totalEarnedPoints
        self.availablePoints = availablePoints
        self.lastUpdated = Date()
        // 初期値は空の辞書をエンコードしておく
        self.difficultQuestionBonus_Data = try? JSONEncoder().encode([String: Int]())
    }
    
    /// 基本ポイントを追加する
    /// - Parameters:
    ///   - points: 追加するポイント
    ///   - context: モデルコンテキスト（履歴記録のため）
    func addPoints(_ points: Int, context: ModelContext? = nil) {
        totalEarnedPoints += points
        availablePoints += points
        lastUpdated = Date()
        
        // 履歴を記録（コンテキストが提供されている場合）
        if let context = context {
            let history = PointHistory(
                date: Date(),
                pointsEarned: points,
                isBonus: false
            )
            context.insert(history)
            try? context.save()
        }
    }
    
    /// 苦手問題に対するボーナスポイントを計算して追加する
    /// - Parameters:
    ///   - questionId: 問題の識別子
    ///   - basePoints: 基本ポイント
    ///   - context: モデルコンテキスト（履歴記録のため）
    /// - Returns: 獲得した合計ポイント (基本ポイント + ボーナスポイント)
    func addDifficultBonus(for questionId: String, basePoints: Int, context: ModelContext? = nil) -> Int {
        // 現在までのボーナス累計を取得
        var bonusDict = difficultQuestionBonuses
        let currentBonus = bonusDict[questionId] ?? 0
        
        // 問題ごとのボーナス上限（不正防止のため）
        let maxBonusPerQuestion = 10
        let bonusLimit = maxBonusPerQuestion - currentBonus
        
        // ボーナスが上限に達している場合は基本ポイントのみ
        if bonusLimit <= 0 {
            addPoints(basePoints, context: context)
            return basePoints
        }
        
        // ボーナスは基本ポイントの50%（上限あり）
        let bonusPoints = min(basePoints / 2 + 1, bonusLimit)
        
        // ボーナス履歴を更新
        bonusDict[questionId] = currentBonus + bonusPoints
        difficultQuestionBonuses = bonusDict
        
        // 合計ポイント
        let totalPointsEarned = basePoints + bonusPoints
        
        // 基本ポイント追加
        addPoints(basePoints, context: nil) // 履歴は後でまとめて追加
        
        // ボーナスポイント追加
        totalEarnedPoints += bonusPoints
        availablePoints += bonusPoints
        
        // 履歴を記録（コンテキストが提供されている場合）
        if let context = context {
            // 基本ポイントの履歴
            let baseHistory = PointHistory(
                date: Date(),
                pointsEarned: basePoints,
                questionId: questionId,
                isBonus: false
            )
            context.insert(baseHistory)
            
            // ボーナスポイントの履歴
            let bonusHistory = PointHistory(
                date: Date(),
                pointsEarned: bonusPoints,
                questionId: questionId,
                isBonus: true
            )
            context.insert(bonusHistory)
            try? context.save()
        }
        
        lastUpdated = Date()
        return totalPointsEarned
    }
    
    /// ポイントを消費する
    /// - Parameters:
    ///   - points: 消費するポイント
    ///   - reason: 消費理由（オプション）
    ///   - context: モデルコンテキスト（履歴記録のため）
    /// - Returns: 消費に成功したかどうか
    @discardableResult
    func spendPoints(_ points: Int, reason: String? = nil, context: ModelContext? = nil) -> Bool {
        // 使用可能ポイントが足りない場合は失敗
        if availablePoints < points {
            return false
        }
        
        // ポイントを消費
        availablePoints -= points
        lastUpdated = Date()
        
        // 履歴を記録（コンテキストが提供されている場合）
        if let context = context {
            let history = PointSpending(
                date: Date(),
                pointsSpent: points,
                reason: reason ?? "ポイント交換"
            )
            context.insert(history)
            try? context.save()
        }
        
        return true
    }
    
    /// ポイントをリセットする
    /// - Parameter context: モデルコンテキスト（履歴記録のため）
    func resetPoints(context: ModelContext? = nil) {
        if availablePoints > 0 {
            // 履歴を記録（コンテキストが提供されている場合）
            if let context = context {
                let history = PointSpending(
                    date: Date(),
                    pointsSpent: availablePoints,
                    reason: "ポイントリセット"
                )
                context.insert(history)
                try? context.save()
            }
            
            // 利用可能ポイントをゼロに
            availablePoints = 0
            lastUpdated = Date()
        }
    }
}
