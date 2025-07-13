import SwiftUI
import SwiftData
import Combine

@MainActor
final class MultiplicationViewState: ObservableObject {
    // 表示用の状態
    @Published var question: MultiplicationQuestion? = nil
    @Published var resultMessage: String = ""
    @Published var answerChoices: [Int] = []
    @Published var isChallengeModeActive = false
    @Published var isAnswering = false
    
    // 段選択関連の状態
    @Published var showingTableSelection = false
    @Published var selectedTable: Int? = nil
    
    // 順番問題関連の状態
    @Published var isSequentialMode = false
    @Published var currentSequentialNumber = 1
    
    // 虫食い問題関連の状態
    @Published var isHolePunchMode = false
    
    // タイマー関連の状態
    @Published var remainingTime: Double = GameConstants.Timer.questionTimeLimit
    @Published var isTimerRunning: Bool = false
    private var timerCancellable: AnyCancellable?
    private var questionStartTime: Date?
    
    // PIN認証関連の状態
    @Published var showingPINAuth = false
    @Published var isAuthenticated = false
    
    // SwiftDataの参照
    private var difficultQuestions: [DifficultQuestion] = []
    private var userPoints: [UserPoints] = []
    private var modelContext: ModelContext?
    
    init() {
        // 初期化時はモデルコンテキストなしで開始
        // updateModelContext で後から設定される
    }
    
    deinit {
        // deinit 内で直接タイマーを停止（クロージャなし）
        timerCancellable?.cancel()
        timerCancellable = nil
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
        guard let modelContext = modelContext else { return }
        
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
        guard let modelContext = modelContext else { return }
        
        let descriptor = FetchDescriptor<UserPoints>()
        do {
            let fetchedPoints = try modelContext.fetch(descriptor)
            if fetchedPoints.isEmpty {
                // ポイントが存在しない場合は新規作成
                let newPoints = UserPoints(totalEarnedPoints: 0, availablePoints: 0)
                modelContext.insert(newPoints)
                try modelContext.save()
                userPoints = [newPoints]
                print("新しいユーザーポイントを作成しました")
            } else {
                // 既存のポイントを使用
                userPoints = fetchedPoints
                print("既存のユーザーポイントを読み込みました: \(fetchedPoints.first?.availablePoints ?? 0)")
            }
        } catch {
            print("ユーザーポイントの確認に失敗しました: \(error)")
            // エラーの場合は新規作成
            let newPoints = UserPoints(totalEarnedPoints: 0, availablePoints: 0)
            modelContext.insert(newPoints)
            try? modelContext.save()
            userPoints = [newPoints]
        }
    }
    
    /// 現在の使用可能ポイントを取得
    func getCurrentPoints() -> Int {
        // userPointsが空の場合、再度確認
        if userPoints.isEmpty {
            ensureUserPointsExists()
        }
        if let points = userPoints.first?.availablePoints {
            return points
        }
        return 0
    }
    
    /// タイマーを開始する
    private func startTimer() {
        stopTimer() // 既存のタイマーをクリア
        
        remainingTime = 10.0 // タイマーをリセット
        questionStartTime = Date() // 開始時間を記録
        isTimerRunning = true
        
        // 0.1秒ごとにタイマーを更新
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.remainingTime > 0 {
                    self.remainingTime -= 0.1
                    // 小数点以下の誤差を修正
                    if self.remainingTime < 0.09 {
                        self.remainingTime = 0
                    }
                } else {
                    // 時間切れ
                    self.handleTimeOut()
                }
            }
    }
    
    /// タイマーを停止する
    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
        isTimerRunning = false
    }
    
    /// 問題をキャンセルする（ゲームを停止する）
    func cancelQuestion() {
        // 進行中の回答をキャンセル
        isAnswering = false
        // タイマーを停止
        stopTimer()
        // 問題をリセット
        question = nil
        // 結果メッセージをクリア
        resultMessage = ""
        // 選択肢をクリア
        answerChoices = []
        // 選択された段をリセット
        selectedTable = nil
        // 順番モードをリセット
        isSequentialMode = false
        currentSequentialNumber = 1
        // 虫食い問題モードをリセット
        isHolePunchMode = false
    }
    
    /// 時間切れの処理
    private func handleTimeOut() {
        guard let question = question, !isAnswering else { return }
        
        isAnswering = true
        stopTimer()
        
        // 通常モードと虫食い問題モードで正解が異なる
        let correctAnswer = isHolePunchMode ? question.secondNumber : question.answer
        resultMessage = "時間切れ！正解は \(correctAnswer) です。"
        
        recordIncorrectAnswer(for: question)
        
        // 回答時間を記録（時間切れは10秒固定）
        recordAnswerTime(for: question, answerTime: 10.0, isCorrect: false, isTimeout: true)
        
        // 少し待ってから新しい問題を生成
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2秒待機
            
            // 虫食い問題モードの場合は次の虫食い問題を生成
            if isHolePunchMode {
                generateHolePunchQuestion()
            }
            // 段が選択されている場合はその段の問題を生成
            else if let selectedTable = selectedTable {
                generateQuestionForTable(selectedTable)
            } 
            // それ以外はランダム問題
            else {
                generateRandomQuestion()
            }
        }
    }
    
    /// 解答時間を計算する（秒単位）
    private func calculateAnswerTime() -> Double? {
        guard let startTime = questionStartTime else { return nil }
        return Date().timeIntervalSince(startTime)
    }
    
    /// 回答時間を記録する
    /// - Parameters:
    ///   - question: 問題
    ///   - answerTime: 回答時間（秒）
    ///   - isCorrect: 正解かどうか
    ///   - isTimeout: 時間切れかどうか
    private func recordAnswerTime(for question: MultiplicationQuestion, answerTime: Double, isCorrect: Bool, isTimeout: Bool = false) {
        // 回答時間記録を作成
        let record = AnswerTimeRecord(
            date: Date(),
            questionId: question.identifier,
            answerTimeSeconds: answerTime,
            isCorrect: isCorrect,
            isTimeout: isTimeout
        )
        
        // SwiftDataに保存
        modelContext?.insert(record)
        try? modelContext?.save()
    }
    
    /// 問題の平均回答時間を取得する
    /// - Parameter questionId: 問題識別子
    /// - Returns: 平均回答時間（秒）、なければnil
    func getAverageAnswerTime(for questionId: String) -> Double? {
        guard let modelContext = modelContext else { return nil }
        return AnswerTimeRecord.getAverageTimeForQuestion(questionId, context: modelContext)
    }
    
    /// ランダムな掛け算問題を生成する
    func generateRandomQuestion() {
        // 回答状態をリセット
        isAnswering = false
        
        // 虫食いモードをリセット
        isHolePunchMode = false
        
        // ランダム問題を生成する場合は段の選択をリセット
        selectedTable = nil
        
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
        
        // 問題生成後にタイマーを開始
        startTimer()
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
    
    /// 正解時に加算するポイントを計算する（苦手問題の場合はボーナスポイント）
    private func calculatePointsForAnswer(for question: MultiplicationQuestion) -> Int {
        if isDifficultQuestion(question) {
            return 2  // 苦手問題ならボーナスポイント
        }
        return 1  // 通常のポイント
    }
    
    /// 回答をチェックする（既存メソッドの拡張）
    func checkAnswer(selectedAnswer: Int) {
        guard let question = question, !isAnswering else { return }
        
        // 回答中状態にする
        isAnswering = true
        
        // タイマーを停止
        stopTimer()
        
        // 回答にかかった時間を計算
        var answerTime: TimeInterval = 10.0
        if let startTime = questionStartTime {
            answerTime = Date().timeIntervalSince(startTime)
        }
        
        // 正解かどうかをチェック（虫食い問題の場合は secondNumber が正解）
        let isCorrect: Bool
        if isHolePunchMode {
            isCorrect = selectedAnswer == question.secondNumber
        } else {
            isCorrect = selectedAnswer == question.answer
        }
        
        if isCorrect {
            // 正解の場合
            // 苦手問題ならボーナスポイント
            let isDifficult = isDifficultQuestion(question)
            let pointsToAdd = isDifficult ? 2 : 1
            
            // ポイント追加
            addPoint(amount: pointsToAdd, reason: "問題正解")
            
            // 解答時間のフィードバック
            let timeMessage = String(format: "%.1f", answerTime)
            resultMessage = "正解！ +\(isDifficult ? "ボーナス" : "1")ポイント (時間: \(timeMessage)秒)"
            
            // 正解時間を記録
            recordAnswerTime(for: question, answerTime: answerTime, isCorrect: true)
            
            // 苦手問題に正解した場合、正解カウントを増やす
            if let difficultQuestion = findDifficultQuestion(for: question) {
                difficultQuestion.increaseCorrectCount()
                try? modelContext?.save()
            }
            
            // 次の問題を準備
            if isSequentialMode && selectedTable != nil {
                // 順番問題の場合は次の問題へ
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    guard let self = self else { return }
                    if let selectedTable = self.selectedTable {
                        self.generateNextSequentialQuestion(for: selectedTable)
                    }
                    self.isAnswering = false
                }
            } else {
                // 通常問題の場合は次の問題への準備
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    guard let self = self else { return }
                    self.isAnswering = false
                    
                    // 虫食い問題モードの場合は次の虫食い問題を生成
                    if self.isHolePunchMode {
                        self.generateHolePunchQuestion()
                    } else if let selectedTable = self.selectedTable {
                        // 段が選択されている場合はその段の問題を生成
                        self.generateQuestionForTable(selectedTable)
                    } else {
                        // それ以外はランダム問題
                        self.generateRandomQuestion()
                    }
                }
            }
        } else {
            // 不正解の場合
            let correctAnswer = isHolePunchMode ? question.secondNumber : question.answer
            resultMessage = "不正解！正解は \(correctAnswer) です。もう一度チャレンジしてね。"
            
            // 間違えた問題を記録
            if let modelContext = modelContext {
                DifficultQuestion.recordIncorrectAnswer(
                    firstNumber: question.firstNumber,
                    secondNumber: question.secondNumber,
                    context: modelContext
                )
            }
            
            // 回答時間を記録（不正解）
            recordAnswerTime(for: question, answerTime: answerTime, isCorrect: false)
            
            // 最新の苦手問題データを読み込み
            loadData()
            
            // 少し時間をおいて次の問題を表示
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self = self else { return }
                self.isAnswering = false
                
                // 虫食い問題モードの場合は次の虫食い問題を生成
                if self.isHolePunchMode {
                    self.generateHolePunchQuestion()
                } else if isSequentialMode, let selectedTable = self.selectedTable {
                    // 順番問題モードの場合は次の問題へ
                    self.generateNextSequentialQuestion(for: selectedTable)
                } else if let selectedTable = self.selectedTable {
                    // 段が選択されている場合はその段の問題を生成
                    self.generateQuestionForTable(selectedTable)
                } else {
                    // それ以外はランダム問題
                    self.generateRandomQuestion()
                }
            }
        }
    }
    
    /// 直近の回答時間記録を取得する
    /// - Parameter limit: 取得する最大数
    /// - Returns: 回答時間記録の配列
    func getRecentAnswerTimeRecords(limit: Int = 10) -> [AnswerTimeRecord] {
        guard let modelContext = modelContext else { return [] }
        return AnswerTimeRecord.getRecentRecords(limit: limit, context: modelContext)
    }
    
    /// 日別の平均回答時間を取得する
    /// - Parameter days: 過去何日分を取得するか
    /// - Returns: 日付と平均回答時間のタプル配列
    func getDailyAverageAnswerTimes(days: Int = 7) -> [(date: Date, average: Double)] {
        guard let modelContext = modelContext else { return [] }
        return AnswerTimeRecord.getDailyAverages(days: days, context: modelContext)
    }
    
    /// 全問題の平均回答時間を取得する
    /// - Returns: 問題IDと平均回答時間の辞書
    func getAllAverageAnswerTimes() -> [String: Double] {
        guard let modelContext = modelContext else { return [:] }
        return AnswerTimeRecord.getAverageAnswerTimes(context: modelContext)
    }
    
    /// 問題が苦手問題かどうかを判定
    private func isDifficultQuestion(_ question: MultiplicationQuestion) -> Bool {
        if let existingRecord = findDifficultQuestion(for: question) {
            return existingRecord.isDifficult
        }
        return false
    }
    
    /// 正解時のポイント加算
    private func addPointsForCorrectAnswer(for question: MultiplicationQuestion, isDifficult: Bool, answerTime: Double) {
        guard let points = userPoints.first else {
            ensureUserPointsExists()
            return
        }
        
        let basePoints = 1 // 基本ポイント
        
        if isDifficult {
            // 苦手問題の場合はボーナスポイント計算
            _ = points.addDifficultBonus(for: question.identifier, basePoints: basePoints, context: modelContext)
            // resultMessageはcheckAnswer内で設定するので、ここでは不要
        } else {
            // 通常問題の場合は基本ポイントのみ
            points.addPoints(basePoints, context: modelContext)
            // resultMessageはcheckAnswer内で設定するので、ここでは不要
        }
        
        try? modelContext?.save()
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
            modelContext?.insert(newDifficultQuestion)
            difficultQuestions.append(newDifficultQuestion)
        }
        // 変更を保存
        try? modelContext?.save()
    }
    
    /// 問題に正解した記録を更新する
    private func recordCorrectAnswer(for question: MultiplicationQuestion) {
        // 既存の記録があるか確認
        if let existingRecord = findDifficultQuestion(for: question) {
            existingRecord.increaseCorrectCount()
        } else {
            // 新しい記録を作成（正解から始まる記録）
            let newDifficultQuestion = DifficultQuestion(
                identifier: question.identifier,
                firstNumber: question.firstNumber,
                secondNumber: question.secondNumber
            )
            // 正解で始まるので不正解カウントを0にして正解カウントを1に設定
            newDifficultQuestion.incorrectCount = 0
            newDifficultQuestion.correctCount = 1
            modelContext?.insert(newDifficultQuestion)
            difficultQuestions.append(newDifficultQuestion)
        }
        // 変更を保存
        try? modelContext?.save()
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
    
    /// 指定された段の問題を生成する
    func generateQuestionForTable(_ table: Int) {
        // 回答状態をリセット
        isAnswering = false
        
        // 虫食いモードをリセット
        isHolePunchMode = false
        
        if isChallengeModeActive && !difficultQuestions.isEmpty && Bool.random() {
            // チャレンジモードの場合でも、指定された段を優先する
            let difficultOnes = difficultQuestions.filter { $0.isDifficult && $0.firstNumber == table }
            if !difficultOnes.isEmpty {
                let randomDifficult = difficultOnes.randomElement()!
                question = MultiplicationQuestion(firstNumber: randomDifficult.firstNumber, 
                                                secondNumber: randomDifficult.secondNumber)
            } else {
                // 指定された段の問題をランダムに生成
                let number = Int.random(in: 1...9)
                question = MultiplicationQuestion(firstNumber: table, secondNumber: number)
            }
        } else {
            // 指定された段の問題をランダムに生成
            let number = Int.random(in: 1...9)
            question = MultiplicationQuestion(firstNumber: table, secondNumber: number)
        }
        
        generateAnswerChoices()
        resultMessage = ""
        
        // 問題生成後にタイマーを開始
        startTimer()
    }
    
    /// 段選択画面を表示
    func showTableSelection() {
        showingTableSelection = true
    }
    
    /// 段を選択して問題を生成（順番モードと通常モードの分岐）
    func selectTable(_ table: Int) {
        selectedTable = table
        showingTableSelection = false
        
        if isSequentialMode {
            // 順番モードの場合は最初から順番に出題
            currentSequentialNumber = 1
            generateNextSequentialQuestion(for: table)
        } else {
            // 通常モードの場合はランダムに出題
            generateQuestionForTable(table)
        }
    }
    
    /// 順番モードを開始する
    func startSequentialMode() {
        showingTableSelection = true
        isSequentialMode = true
        currentSequentialNumber = 1
        // 虫食いモードをリセット
        isHolePunchMode = false
    }
    
    /// 順番モードで次の問題を生成する
    private func generateNextSequentialQuestion(for table: Int) {
        // 最後の問題（9）まで解き終わったかチェック
        if currentSequentialNumber > 9 {
            // 順番モード終了
            resultMessage = "おめでとう！\(table)の だんを すべて クリアしました！"
            question = nil
            stopTimer()
            isSequentialMode = false
            currentSequentialNumber = 1
            isAnswering = false
            return
        }
        
        // 回答状態をリセット
        isAnswering = false
        
        // 次の順番の問題を生成
        question = MultiplicationQuestion(firstNumber: table, secondNumber: currentSequentialNumber)
        
        // 次の数字に進める
        currentSequentialNumber += 1
        
        generateAnswerChoices()
        
        // 問題生成後にタイマーを開始
        startTimer()
    }
    
    /// 虫食い問題を生成する（かける数を答える問題）
    func generateHolePunchQuestion() {
        // 回答状態をリセット
        isAnswering = false
        
        // モードをセット
        isHolePunchMode = true
        
        // 段の選択をリセット
        selectedTable = nil
        
        if isChallengeModeActive && !difficultQuestions.isEmpty && Bool.random() {
            // 50%の確率で苦手問題から選択
            let difficultOnes = difficultQuestions.filter { $0.isDifficult }
            if !difficultOnes.isEmpty {
                let randomDifficult = difficultOnes.randomElement()!
                // 虫食い問題なので、問題の形式を変える（答えが2番目の数になる）
                question = MultiplicationQuestion(firstNumber: randomDifficult.firstNumber, 
                                                secondNumber: randomDifficult.secondNumber)
            } else {
                let firstNumber = Int.random(in: 1...9)
                let secondNumber = Int.random(in: 1...9)
                question = MultiplicationQuestion(firstNumber: firstNumber, secondNumber: secondNumber)
            }
        } else {
            // 通常のランダム問題
            let firstNumber = Int.random(in: 1...9)
            let secondNumber = Int.random(in: 1...9)
            question = MultiplicationQuestion(firstNumber: firstNumber, secondNumber: secondNumber)
        }
        
        // 虫食い問題用の選択肢を生成（答えが2番目の数になる）
        generateHolePunchAnswerChoices()
        resultMessage = ""
        
        // 問題生成後にタイマーを開始
        startTimer()
    }
    
    /// 虫食い問題用の選択肢をランダムに生成する
    private func generateHolePunchAnswerChoices() {
        guard let question = question else { return }
        
        // 虫食い問題では、正解は2番目の数（secondNumber）
        var choices = [question.secondNumber]
        
        // 選択肢の数をランダムに決定（6〜8個）
        let numberOfChoices = Int.random(in: 6...8)
        
        // 1〜9の範囲の数字から選択肢を作成
        while choices.count < numberOfChoices {
            let randomChoice = Int.random(in: 1...9)
            
            // 重複を避ける
            if !choices.contains(randomChoice) {
                choices.append(randomChoice)
            }
        }
        
        // 選択肢をシャッフル
        answerChoices = choices.shuffled()
    }
    
    /// ポイントを加算する
    private func addPoint(amount: Int, reason: String) {
        guard let points = userPoints.first else {
            ensureUserPointsExists()
            return
        }
        
        points.addPoints(amount, context: modelContext)
        try? modelContext?.save()
    }
}
