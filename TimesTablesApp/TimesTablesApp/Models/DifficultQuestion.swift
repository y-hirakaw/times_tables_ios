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
    
    /// 保存されている全ての苦手問題を取得
    /// - Parameter context: ModelContext
    /// - Returns: 苦手問題の配列
    static func getAllDifficultQuestions(context: ModelContext) -> [DifficultQuestion] {
        let descriptor = FetchDescriptor<DifficultQuestion>()
        do {
            let questions = try context.fetch(descriptor)
            return questions
        } catch {
            print("苦手問題の取得に失敗しました: \(error)")
            return []
        }
    }
    
    /// 問題が間違えられた時に呼び出すメソッド
    /// 既存の苦手問題があれば更新し、無ければ新規作成する
    /// - Parameters:
    ///   - firstNumber: 掛けられる数
    ///   - secondNumber: 掛ける数
    ///   - context: ModelContext
    static func recordIncorrectAnswer(firstNumber: Int, secondNumber: Int, context: ModelContext) {
        let identifier = "\(firstNumber)x\(secondNumber)"
        
        // 既存の問題を検索
        let descriptor = FetchDescriptor<DifficultQuestion>(
            predicate: #Predicate { $0.identifier == identifier }
        )
        
        do {
            let existingQuestions = try context.fetch(descriptor)
            if let existingQuestion = existingQuestions.first {
                // 既存の問題があれば不正解カウントを増やす
                existingQuestion.increaseIncorrectCount()
                print("既存の苦手問題を更新: \(identifier)")
            } else {
                // 新しい問題を作成
                let newQuestion = DifficultQuestion(
                    identifier: identifier,
                    firstNumber: firstNumber,
                    secondNumber: secondNumber
                )
                context.insert(newQuestion)
                print("新しい苦手問題を登録: \(identifier)")
            }
            
            // 変更を保存
            try context.save()
        } catch {
            print("苦手問題の保存に失敗: \(error)")
        }
    }
    
    /// デバッグ情報を文字列で取得
    func debugDescription() -> String {
        return """
        問題: \(identifier)
          - 計算式: \(firstNumber) × \(secondNumber) = \(firstNumber * secondNumber)
          - 不正解回数: \(incorrectCount)
          - 正解回数: \(correctCount)
          - 総回答数: \(totalAttempts)
          - 不正解率: \(String(format: "%.1f%%", incorrectPercentage))
          - 最後に間違えた日: \(lastIncorrectDate)
          - 「苦手」判定: \(isDifficult ? "はい" : "いいえ")
        """
    }
    
    /// 指定した日付時点での苦手問題の数を計算
    /// - Parameters:
    ///   - date: 基準日
    ///   - questions: DifficultQuestionのリスト
    /// - Returns: その日時点での苦手問題の数
    static func getDifficultQuestionsCountAt(date: Date, questions: [DifficultQuestion]) -> Int {
        // 指定日以前に不正解だった問題のみをフィルタリング
        let questionsBeforeDate = questions.filter { $0.lastIncorrectDate <= date }
        
        // その中から苦手判定の問題をカウント
        let difficultCount = questionsBeforeDate.filter { question in
            // 問題の状態を特定日時点で再計算
            // 注：この実装は簡略化されており、厳密には正解数も時系列で考慮する必要がある
            return question.incorrectPercentage > 30 && question.totalAttempts >= 3
        }.count
        
        return difficultCount
    }
    
    /// 指定した期間内に改善された問題（苦手判定から通常判定になった問題）を取得
    /// - Parameters:
    ///   - days: 何日前からのデータを見るか
    ///   - questions: DifficultQuestionのリスト
    /// - Returns: 改善された問題のリスト
    static func getImprovedQuestions(within days: Int, questions: [DifficultQuestion]) -> [DifficultQuestion] {
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) else {
            return []
        }
        
        return questions.filter { question in
            // 期間内に回答があり、かつ現在は苦手判定ではない問題
            let hasRecentAttempts = question.lastIncorrectDate >= startDate || question.correctCount > 0
            return hasRecentAttempts && !question.isDifficult && question.totalAttempts >= 3
        }
    }
}
