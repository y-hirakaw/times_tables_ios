import Foundation
import SwiftData

/// ユーザーのポイント情報を管理するモデル
@Model
final class UserPoints {
    /// 合計ポイント
    var totalPoints: Int
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
    
    init(totalPoints: Int = 0) {
        self.totalPoints = totalPoints
        self.lastUpdated = Date()
        // 初期値は空の辞書をエンコードしておく
        self.difficultQuestionBonus_Data = try? JSONEncoder().encode([String: Int]())
    }
    
    /// 基本ポイントを追加する
    /// - Parameter points: 追加するポイント
    func addPoints(_ points: Int) {
        totalPoints += points
        lastUpdated = Date()
    }
    
    /// 苦手問題に対するボーナスポイントを計算して追加する
    /// - Parameters:
    ///   - questionId: 問題の識別子
    ///   - basePoints: 基本ポイント
    /// - Returns: 獲得した合計ポイント (基本ポイント + ボーナスポイント)
    func addDifficultBonus(for questionId: String, basePoints: Int) -> Int {
        // 現在までのボーナス累計を取得
        var bonusDict = difficultQuestionBonuses
        let currentBonus = bonusDict[questionId] ?? 0
        
        // 問題ごとのボーナス上限（不正防止のため）
        let maxBonusPerQuestion = 10
        let bonusLimit = maxBonusPerQuestion - currentBonus
        
        // ボーナスが上限に達している場合は基本ポイントのみ
        if bonusLimit <= 0 {
            addPoints(basePoints)
            return basePoints
        }
        
        // ボーナスは基本ポイントの50%（上限あり）
        let bonusPoints = min(basePoints / 2 + 1, bonusLimit)
        
        // ボーナス履歴を更新
        bonusDict[questionId] = currentBonus + bonusPoints
        difficultQuestionBonuses = bonusDict
        
        // 合計ポイント
        let totalPointsEarned = basePoints + bonusPoints
        addPoints(totalPointsEarned)
        
        return totalPointsEarned
    }
}
