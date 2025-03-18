import Foundation

/// 掛け算の問題を表す構造体
struct MultiplicationQuestion: Identifiable, Equatable {
    /// ユニークなID
    let id = UUID()
    /// 最初の数値（掛けられる数）
    let firstNumber: Int
    /// 二つ目の数値（掛ける数）
    let secondNumber: Int
    
    /// 問題文を生成する
    /// - Returns: 「○ × ○ = ?」形式の問題文
    var question: String {
        return "\(firstNumber) × \(secondNumber) = ?"
    }
    
    /// 問題の正解となる答え
    /// - Returns: 掛け算の結果
    var answer: Int {
        return firstNumber * secondNumber
    }
    
    /// 問題の一意識別子
    /// - Returns: 「数字x数字」形式の文字列（例：「3x4」）
    var identifier: String {
        return "\(firstNumber)x\(secondNumber)"
    }
    
    /// ランダムな掛け算問題を生成する
    /// - Returns: 1から9までのランダムな数値を使用した掛け算問題
    static func randomQuestion() -> MultiplicationQuestion {
        let firstNumber = Int.random(in: 1...9)
        let secondNumber = Int.random(in: 1...9)
        return MultiplicationQuestion(firstNumber: firstNumber, secondNumber: secondNumber)
    }
    
    /// 特定の段と番号の掛け算問題を生成する
    /// - Parameters:
    ///   - table: 何の段か（例：3の段なら3）
    ///   - number: かける数（例：3×4の問題なら4）
    /// - Returns: 指定された数値を使用した掛け算問題
    static func questionFor(table: Int, number: Int) -> MultiplicationQuestion {
        return MultiplicationQuestion(firstNumber: table, secondNumber: number)
    }
}
