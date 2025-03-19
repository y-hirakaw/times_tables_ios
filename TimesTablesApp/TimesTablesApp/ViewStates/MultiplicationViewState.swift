import SwiftUI
import SwiftData

@MainActor
final class MultiplicationViewState: ObservableObject {
    // 表示用の状態
    @Published var question: MultiplicationQuestion? = nil
    @Published var resultMessage: String = ""
    @Published var answerChoices: [Int] = []
    @Published var isChallengeModeActive = false
    @Published var isAnswering = false
    
    // PIN認証関連の状態
    @Published var showingPINAuth = false
    @Published var isAuthenticated = false
    
    // SwiftDataの参照
    private var difficultQuestions: [DifficultQuestion] = []
    private var userPoints: [UserPoints] = []
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        // 初期データをロード
        loadData()
        // アプリ起動時にユーザーポイントが存在することを確認
        ensureUserPointsExists()
    }
    
    /// ModelContextを更新する
    /// - Parameter newContext: 新しいModelContext
    func updateModelContext(_ newContext: ModelContext) {
        self.modelContext = newContext
        // 新しいコンテキストでデータをリロード
        loadData()
        // ModelContextを更新したら再度ユーザーポイントを確認
        ensureUserPointsExists()
    }
    
    /// データをロードする
    private func loadData() {
        do {
            // DifficultQuestionsをロード
            let difficultDescriptor = FetchDescriptor<DifficultQuestion>()
            difficultQuestions = try modelContext.fetch(difficultDescriptor)
            
            // UserPointsをロード
            let pointsDescriptor = FetchDescriptor<UserPoints>()
            userPoints = try modelContext.fetch(pointsDescriptor)
        } catch {
            print("データの読み込みに失敗しました: \(error)")
        }
    }
    
    /// 最新のデータを取得し直す
    func refreshData() {
        loadData()
    }
    
    /// ユーザーポイントが存在することを確認し、なければ作成
    func ensureUserPointsExists() {
        if userPoints.isEmpty {
            let newPoints = UserPoints()
            modelContext.insert(newPoints)
            try? modelContext.save()
            userPoints.append(newPoints)
        }
    }
    
    /// 現在の使用可能ポイントを取得
    func getCurrentPoints() -> Int {
        return userPoints.first?.availablePoints ?? 0
    }
    
    /// ランダムな掛け算問題を生成する
    func generateRandomQuestion() {
        // 回答状態をリセット
        isAnswering = false
        
        if isChallengeModeActive && !difficultQuestions.isEmpty && Bool.random() {
            // 50%の確率で苦手問題から選択
            let difficultOnes = difficultQuestions.filter { $0.isDifficult }
            if !difficultOnes.isEmpty {
                let randomDifficult = difficultOnes.randomElement()!
                question = MultiplicationQuestion(firstNumber: randomDifficult.firstNumber, 
                                                secondNumber: randomDifficult.secondNumber)
            } else {
                question = MultiplicationQuestion.randomQuestion()
            }
        } else {
            // 通常のランダム問題
            question = MultiplicationQuestion.randomQuestion()
        }
        generateAnswerChoices()
        resultMessage = ""
    }
    
    /// 選択肢をランダムに生成する
    private func generateAnswerChoices() {
        guard let question = question else { return }
        
        // 正解を含む選択肢のリストを作成
        var choices = [question.answer]
        
        // 選択肢の数をランダムに決定（6〜8個）
        let numberOfChoices = Int.random(in: 6...8)
        
        // 正解の近辺の数値と他のランダムな数値を追加
        while choices.count < numberOfChoices {
            let randomChoice: Int
            
            // 50%の確率で近い値、50%の確率で完全なランダム値
            if Bool.random() {
                // 正解の近辺の値（±10の範囲）
                let offset = Int.random(in: -10...10)
                randomChoice = max(1, question.answer + offset) // 1未満にならないようにする
            } else {
                // 完全なランダム値（1〜100の範囲）
                randomChoice = Int.random(in: 1...100)
            }
            
            // 重複を避ける
            if !choices.contains(randomChoice) {
                choices.append(randomChoice)
            }
        }
        
        // 選択肢をシャッフル
        answerChoices = choices.shuffled()
    }
    
    /// ユーザーの回答を確認する
    func checkAnswer(selectedAnswer: Int) {
        guard let question = question else { return }
        
        // すでに回答中の場合は処理をスキップ
        if isAnswering { return }
        
        // 回答中フラグを設定して、ボタンを無効化
        isAnswering = true
        
        if selectedAnswer == question.answer {
            // 正解の場合
            let isDifficult = isDifficultQuestion(question)
            addPointsForCorrectAnswer(for: question, isDifficult: isDifficult)
            updateCorrectAttempt(for: question)
            
            // 少し待ってから新しい問題を生成
            Task {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒待機
                generateRandomQuestion()
            }
        } else {
            resultMessage = "不正解。正解は \(question.answer) です。"
            recordIncorrectAnswer(for: question)
            // 少し待ってから新しい問題を生成
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2秒待機
                generateRandomQuestion()
            }
        }
    }
    
    /// 問題が苦手問題かどうかを判定
    private func isDifficultQuestion(_ question: MultiplicationQuestion) -> Bool {
        if let existingRecord = findDifficultQuestion(for: question) {
            return existingRecord.isDifficult
        }
        return false
    }
    
    /// 正解時のポイント加算
    private func addPointsForCorrectAnswer(for question: MultiplicationQuestion, isDifficult: Bool) {
        guard let points = userPoints.first else {
            ensureUserPointsExists()
            return
        }
        
        let basePoints = 1 // 基本ポイント
        
        if isDifficult {
            // 苦手問題の場合はボーナスポイント計算
            let earnedPoints = points.addDifficultBonus(for: question.identifier, basePoints: basePoints, context: modelContext)
            resultMessage = "正解！ +\(earnedPoints)ポイント"
        } else {
            // 通常問題の場合は基本ポイントのみ
            points.addPoints(basePoints, context: modelContext)
            resultMessage = "正解！ +\(basePoints)ポイント"
        }
        
        try? modelContext.save()
        // ポイント更新後にデータを再読み込み
        refreshData()
    }
    
    /// 不正解だった問題を記録する
    private func recordIncorrectAnswer(for question: MultiplicationQuestion) {
        // 既存の記録があるか確認
        if let existingRecord = findDifficultQuestion(for: question) {
            existingRecord.increaseIncorrectCount()
        } else {
            // 新しい記録を作成
            let newDifficultQuestion = DifficultQuestion(
                identifier: question.identifier,
                firstNumber: question.firstNumber,
                secondNumber: question.secondNumber
            )
            modelContext.insert(newDifficultQuestion)
            difficultQuestions.append(newDifficultQuestion)
        }
        // 変更を保存
        try? modelContext.save()
    }
    
    /// 問題に正解した記録を更新する
    private func updateCorrectAttempt(for question: MultiplicationQuestion) {
        // この問題が記録に存在する場合、正解回数を更新
        if let existingRecord = findDifficultQuestion(for: question) {
            existingRecord.increaseCorrectCount()
            try? modelContext.save()
        }
    }
    
    /// 指定された問題に対応する苦手問題の記録を検索する
    private func findDifficultQuestion(for question: MultiplicationQuestion) -> DifficultQuestion? {
        return difficultQuestions.first { $0.identifier == question.identifier }
    }
    
    /// 親用管理画面を表示する処理
    func showParentDashboard() {
        showingPINAuth = true
    }
    
    /// チャレンジモードの切り替え
    func toggleChallengeMode() {
        isChallengeModeActive.toggle()
    }
    
    /// 苦手問題のフィルタリング
    func getDifficultOnes() -> [DifficultQuestion] {
        return difficultQuestions.filter { $0.isDifficult }
    }
}
