import XCTest
import Testing
import SwiftData
@testable import TimesTablesApp

@MainActor
final class UserPointsTests: XCTestCase {
    
    func testInitialValues() throws {
        // UserPointsの初期値テスト
        let points = UserPoints()
        
        #expect(points.totalEarnedPoints == 0)
        #expect(points.availablePoints == 0)
        #expect(points.difficultQuestionBonuses.isEmpty)
    }
    
    func testAddPoints() throws {
        // 基本ポイント追加のテスト
        let points = UserPoints()
        
        points.addPoints(5)
        #expect(points.totalEarnedPoints == 5)
        #expect(points.availablePoints == 5)
        
        points.addPoints(3)
        #expect(points.totalEarnedPoints == 8)
        #expect(points.availablePoints == 8)
    }
    
    func testAddDifficultBonus() throws {
        // 苦手問題ボーナスのテスト
        let points = UserPoints()
        let questionId = "7x8"
        
        // 最初のボーナス（基本ポイント1、ボーナス1）
        let firstEarned = points.addDifficultBonus(for: questionId, basePoints: 1)
        #expect(firstEarned == 2, "最初の苦手問題ボーナスは基本ポイント + ボーナス")
        #expect(points.totalEarnedPoints == 2)
        #expect(points.availablePoints == 2)
        #expect(points.difficultQuestionBonuses[questionId] == 1)
        
        // 2回目のボーナス（基本ポイント1、ボーナス1）
        let secondEarned = points.addDifficultBonus(for: questionId, basePoints: 1)
        #expect(secondEarned == 2)
        #expect(points.totalEarnedPoints == 4)
        #expect(points.availablePoints == 4)
        #expect(points.difficultQuestionBonuses[questionId] == 2)
        
        // 上限に達するまでボーナスを加算
        for _ in 0..<8 {
            points.addDifficultBonus(for: questionId, basePoints: 1)
        }
        
        // 上限後のボーナス（基本ポイントのみ）
        let finalEarned = points.addDifficultBonus(for: questionId, basePoints: 1)
        #expect(finalEarned == 1, "上限に達した後は基本ポイントのみ")
        #expect(points.difficultQuestionBonuses[questionId] == 10, "ボーナスポイントは上限(10)を超えない")
    }
    
    func testMultipleDifficultQuestions() throws {
        // 複数の苦手問題に対するボーナスのテスト
        let points = UserPoints()
        
        let question1 = "3x4"
        let question2 = "7x8"
        
        // 異なる問題のボーナスは個別に追跡される
        let _ = points.addDifficultBonus(for: question1, basePoints: 1)
        let _ = points.addDifficultBonus(for: question2, basePoints: 1)
        
        #expect(points.difficultQuestionBonuses[question1] == 1)
        #expect(points.difficultQuestionBonuses[question2] == 1)
        #expect(points.totalEarnedPoints == 4)
        #expect(points.availablePoints == 4)
    }
    
    func testSpendPoints() throws {
        // ポイント消費のテスト
        let points = UserPoints()
        
        // 初期ポイントを追加
        points.addPoints(10)
        
        // ポイントを使用
        let success1 = points.spendPoints(5)
        #expect(success1)
        #expect(points.availablePoints == 5)
        #expect(points.totalEarnedPoints == 10, "総獲得ポイントは変わらない")
        
        // ポイントが足りない場合
        let success2 = points.spendPoints(10)
        #expect(!success2)
        #expect(points.availablePoints == 5, "失敗時はポイントは減らない")
        
        // 残りのポイントを全て使用
        let success3 = points.spendPoints(5)
        #expect(success3)
        #expect(points.availablePoints == 0)
    }
    
    func testResetPoints() throws {
        // ポイントリセットのテスト
        let points = UserPoints()
        
        // 初期ポイントを追加
        points.addPoints(20)
        #expect(points.availablePoints == 20)
        
        // リセット
        points.resetPoints()
        #expect(points.availablePoints == 0)
        #expect(points.totalEarnedPoints == 20, "総獲得ポイントは変わらない")
    }
    
    func testPointHistoryWithModelContext() throws {
        // ModelContextを使った履歴テスト
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: UserPoints.self, PointHistory.self, PointSpending.self, configurations: config)
        let context = container.mainContext
        
        let points = UserPoints()
        context.insert(points)
        
        // ポイント追加と履歴記録
        points.addPoints(5, context: context)
        let _ = points.addDifficultBonus(for: "7x8", basePoints: 2, context: context)
        
        // 履歴の確認
        let descriptor = FetchDescriptor<PointHistory>()
        let histories = try context.fetch(descriptor)
        
        #expect(histories.count == 3) // 基本5ポイント、基本2ポイント、ボーナスポイントの3つ
        #expect(histories.reduce(0) { $0 + $1.pointsEarned } == 9) // 合計9ポイント獲得
        
        // ポイント消費と履歴記録
        points.spendPoints(3, reason: "テスト消費", context: context)
        
        let spendingDescriptor = FetchDescriptor<PointSpending>()
        let spendings = try context.fetch(spendingDescriptor)
        
        #expect(spendings.count == 1)
        #expect(spendings[0].pointsSpent == 3)
        #expect(spendings[0].reason == "テスト消費")
    }
}
