import XCTest
import Testing
@testable import TimesTablesApp

@MainActor
final class UserPointsTests: XCTestCase {
    
    func testInitialValues() throws {
        // UserPointsの初期値テスト
        let points = UserPoints()
        
        expect(points.totalPoints, equals: 0)
        expect(points.difficultQuestionBonuses.isEmpty, equals: true)
    }
    
    func testAddPoints() throws {
        // 基本ポイント追加のテスト
        let points = UserPoints()
        
        points.addPoints(5)
        expect(points.totalPoints, equals: 5)
        
        points.addPoints(3)
        expect(points.totalPoints, equals: 8)
    }
    
    func testAddDifficultBonus() throws {
        // 苦手問題ボーナスのテスト
        let points = UserPoints()
        let questionId = "7x8"
        
        // 最初のボーナス（基本ポイント1、ボーナス1）
        let firstEarned = points.addDifficultBonus(for: questionId, basePoints: 1)
        expect(firstEarned, equals: 2, "最初の苦手問題ボーナスは基本ポイント + ボーナス")
        expect(points.totalPoints, equals: 2)
        expect(points.difficultQuestionBonuses[questionId], equals: 1)
        
        // 2回目のボーナス（基本ポイント1、ボーナス1）
        let secondEarned = points.addDifficultBonus(for: questionId, basePoints: 1)
        expect(secondEarned, equals: 2)
        expect(points.totalPoints, equals: 4)
        expect(points.difficultQuestionBonuses[questionId], equals: 2)
        
        // 上限に達するまでボーナスを加算
        for _ in 0..<8 {
            points.addDifficultBonus(for: questionId, basePoints: 1)
        }
        
        // 上限後のボーナス（基本ポイントのみ）
        let finalEarned = points.addDifficultBonus(for: questionId, basePoints: 1)
        expect(finalEarned, equals: 1, "上限に達した後は基本ポイントのみ")
        expect(points.difficultQuestionBonuses[questionId], equals: 10, "ボーナスポイントは上限(10)を超えない")
    }
    
    func testMultipleDifficultQuestions() throws {
        // 複数の苦手問題に対するボーナスのテスト
        let points = UserPoints()
        
        let question1 = "3x4"
        let question2 = "7x8"
        
        // 異なる問題のボーナスは個別に追跡される
        points.addDifficultBonus(for: question1, basePoints: 1)
        points.addDifficultBonus(for: question2, basePoints: 1)
        
        expect(points.difficultQuestionBonuses[question1], equals: 1)
        expect(points.difficultQuestionBonuses[question2], equals: 1)
        expect(points.totalPoints, equals: 4)
    }
}
