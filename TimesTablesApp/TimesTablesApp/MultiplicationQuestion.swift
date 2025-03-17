import Foundation

struct MultiplicationQuestion {
    let multiplicand: Int
    let multiplier: Int

    var question: String {
        return "\(multiplicand) × \(multiplier)"
    }

    var answer: Int {
        return multiplicand * multiplier
    }

    static func randomQuestion() -> MultiplicationQuestion {
        let multiplicand = Int.random(in: 1...9)
        let multiplier = Int.random(in: 1...9)
        return MultiplicationQuestion(multiplicand: multiplicand, multiplier: multiplier)
    }

    static func question(for multiplicand: Int) -> MultiplicationQuestion {
        let multiplier = Int.random(in: 1...9)
        return MultiplicationQuestion(multiplicand: multiplicand, multiplier: multiplier)
    }
}