import XCTest
import SwiftData
import Testing
@testable import TimesTablesApp

@MainActor
final class MultiplicationViewStateTests: XCTestCase {
    
    // テスト用のインメモリModelContextを作成
    func createInMemoryModelContext() -> ModelContext {
        let schema = Schema([
            DifficultQuestion.self,
            UserPoints.self,
            PointHistory.self,
            PointSpending.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let modelContainer = try! ModelContainer(for: schema, configurations: [modelConfiguration])
        return ModelContext(modelContainer)
    }
    
    func test_初期化時に正しく設定される() async throws {
        // Arrange
        let modelContext = createInMemoryModelContext()
        
        // Act
        let viewState = MultiplicationViewState(modelContext: modelContext)
        
        // Assert
        let userPointsDescriptor = FetchDescriptor<UserPoints>()
        let userPoints = try modelContext.fetch(userPointsDescriptor)
        XCTAssertEqual(userPoints.count, 1, "UserPointsが作成されていること")
        XCTAssertEqual(viewState.getCurrentPoints(), 0, "初期ポイントは0であること")
        XCTAssertNil(viewState.question, "初期状態では問題がないこと")
        XCTAssertFalse(viewState.isChallengeModeActive, "初期状態ではチャレンジモードがオフであること")
    }
    
    func test_ランダム問題生成が正しく動作する() async throws {
        // Arrange
        let modelContext = createInMemoryModelContext()
        let viewState = MultiplicationViewState(modelContext: modelContext)
        
        // Act
        viewState.generateRandomQuestion()
        
        // Assert
        XCTAssertNotNil(viewState.question, "問題が生成されていること")
        XCTAssertFalse(viewState.answerChoices.isEmpty, "選択肢が生成されていること")
        XCTAssertTrue(viewState.answerChoices.contains(viewState.question!.answer), "選択肢に正解が含まれていること")
        XCTAssertTrue(viewState.resultMessage.isEmpty, "メッセージが初期化されていること")
    }
    
    func test_正解時に正しくポイントが加算される() async throws {
        // Arrange
        let modelContext = createInMemoryModelContext()
        let viewState = MultiplicationViewState(modelContext: modelContext)
        viewState.generateRandomQuestion()
        let question = viewState.question!
        
        // Act
        viewState.checkAnswer(selectedAnswer: question.answer)
        
        // Wait for async operations to complete
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        XCTAssertEqual(viewState.getCurrentPoints(), 1, "正解で1ポイント加算されること")
        XCTAssertTrue(viewState.resultMessage.contains("正解"), "正解のメッセージが表示されること")
    }
    
    func test_不正解時に正しく処理される() async throws {
        // Arrange
        let modelContext = createInMemoryModelContext()
        let viewState = MultiplicationViewState(modelContext: modelContext)
        viewState.generateRandomQuestion()
        let question = viewState.question!
        let wrongAnswer = question.answer + 1 // 確実に間違う答え
        
        // Act
        viewState.checkAnswer(selectedAnswer: wrongAnswer)
        
        // Wait for async operations to complete
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        XCTAssertEqual(viewState.getCurrentPoints(), 0, "不正解ではポイントが加算されないこと")
        XCTAssertTrue(viewState.resultMessage.contains("不正解"), "不正解のメッセージが表示されること")
        
        // 苦手問題が記録されていることを確認
        let difficultQuestionsDescriptor = FetchDescriptor<DifficultQuestion>()
        let difficultQuestions = try modelContext.fetch(difficultQuestionsDescriptor)
        XCTAssertEqual(difficultQuestions.count, 1, "不正解の問題が記録されていること")
        XCTAssertEqual(difficultQuestions[0].identifier, question.identifier, "正しい問題が記録されていること")
        XCTAssertEqual(difficultQuestions[0].incorrectCount, 1, "不正解回数が記録されていること")
    }
    
    func test_苦手問題が正しく識別される() async throws {
        // Arrange
        let modelContext = createInMemoryModelContext()
        
        // 苦手問題を作成: 3回不正解、1回正解の3×4の問題
        let difficultQuestion = DifficultQuestion(identifier: "3x4", firstNumber: 3, secondNumber: 4)
        difficultQuestion.incorrectCount = 3
        difficultQuestion.correctCount = 1
        modelContext.insert(difficultQuestion)
        try modelContext.save()
        
        let viewState = MultiplicationViewState(modelContext: modelContext)
        // データをリフレッシュして明示的に読み込む
        viewState.refreshData()
        
        // Act
        let difficultOnes = viewState.getDifficultOnes()
        
        // Assert
        XCTAssertEqual(difficultOnes.count, 1, "1つの苦手問題が検出されること")
        XCTAssertEqual(difficultOnes[0].identifier, "3x4", "正しい問題が検出されること")
    }
    
    func test_チャレンジモードの切り替えが正しく動作する() async throws {
        // Arrange
        let modelContext = createInMemoryModelContext()
        let viewState = MultiplicationViewState(modelContext: modelContext)
        
        // Act & Assert
        XCTAssertFalse(viewState.isChallengeModeActive, "初期状態ではオフ")
        viewState.toggleChallengeMode()
        XCTAssertTrue(viewState.isChallengeModeActive, "トグル後はオン")
        viewState.toggleChallengeMode()
        XCTAssertFalse(viewState.isChallengeModeActive, "再度トグルするとオフ")
    }
    
    func test_苦手問題の正解時にボーナスポイントが加算される() async throws {
        // Arrange
        let modelContext = createInMemoryModelContext()
        
        // ユーザーポイントを設定
        let userPoints = UserPoints()
        modelContext.insert(userPoints)
        
        // 苦手問題を作成
        let difficultQuestion = DifficultQuestion(identifier: "5x6", firstNumber: 5, secondNumber: 6)
        difficultQuestion.incorrectCount = 3
        difficultQuestion.correctCount = 0
        modelContext.insert(difficultQuestion)
        try modelContext.save()
        
        let viewState = MultiplicationViewState(modelContext: modelContext)
        
        // 明示的に苦手問題を設定して回答する
        let testQuestion = MultiplicationQuestion(firstNumber: 5, secondNumber: 6)
        viewState.question = testQuestion
        viewState.checkAnswer(selectedAnswer: testQuestion.answer)
        
        // Wait for async operations to complete
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        let updatedPoints = viewState.getCurrentPoints()
        XCTAssertGreaterThan(updatedPoints, 1, "ボーナスポイントが加算されて1より大きいこと")
        XCTAssertTrue(viewState.resultMessage.contains("+"), "ポイント加算メッセージが表示されること")
    }
}