import Foundation
import SwiftData

/// ユーザーが苦手とする掛け算問題を追跡するためのモデル
@Model
final class DifficultQuestion {
    /// 問題の一意識別子（例：「3x4」）
    var identifier: String
    /// 最初の数値（掛けられる数）
    var firstNumber: Int
    /// 二つ目の数値（掛ける数）
    var secondNumber: Int
    /// 不正解の回数
    var incorrectCount: Int
    /// 正解の回数
    var correctCount: Int
    /// 最後に不正解だった日時
    var lastIncorrectDate: Date
    
    /// 新しい苦手問題を初期化
    /// - Parameters:
    ///   - identifier: 問題の一意識別子
    ///   - firstNumber: 掛けられる数
    ///   - secondNumber: 掛ける数
    init(identifier: String, firstNumber: Int, secondNumber: Int) {
        self.identifier = identifier
        self.firstNumber = firstNumber
        self.secondNumber = secondNumber
        self.incorrectCount = 1
        self.correctCount = 0
        self.lastIncorrectDate = Date()
    }
    
    /// 不正解回数を増加させる
    func increaseIncorrectCount() {
        incorrectCount += 1
        lastIncorrectDate = Date()
    }
    
    /// 正解回数を増加させる
    func increaseCorrectCount() {
        correctCount += 1
    }
    
    /// 問題への総回答回数
    var totalAttempts: Int {
        return correctCount + incorrectCount
    }
    
    /// 不正解率（%）
    var incorrectPercentage: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(incorrectCount) / Double(totalAttempts) * 100
    }
    
    /// この問題が「苦手」判定かどうか
    /// 全回答が3回以上かつ不正解率が30%を超える場合に「苦手」と判定
    var isDifficult: Bool {
        return totalAttempts >= 3 && incorrectPercentage > 30
    }
}
