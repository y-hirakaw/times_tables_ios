import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var question: MultiplicationQuestion? = nil
    @State private var resultMessage: String = ""
    @State private var answerChoices: [Int] = []
    /// 苦手問題のリストをSwiftDataから取得
    @Query private var difficultQuestions: [DifficultQuestion]
    /// ユーザーポイントの取得
    @Query private var userPoints: [UserPoints]
    /// SwiftDataのモデルコンテキスト
    @Environment(\.modelContext) private var modelContext
    /// 苦手問題チャレンジモードの状態
    @State private var isChallengeModeActive = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let question = question {
                    Text(question.question)
                        .font(.title)
                        .padding()
                    
                    // 選択肢ボタンのグリッド
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(answerChoices, id: \.self) { choice in
                            Button(action: {
                                checkAnswer(selectedAnswer: choice)
                            }) {
                                Text("\(choice)")
                                    .font(.title2)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(10)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    .padding()
                    
                    Text(resultMessage)
                        .foregroundColor(resultMessage.contains("正解") ? .green : .red)
                        .font(.headline)
                        .padding()
                    
                    Text("獲得ポイント: \(getCurrentPoints())")
                } else {
                    Text("ボタンを押して問題を表示しよう！")
                        .font(.title)
                        .padding()
                }
                
                HStack {
                    Button(action: generateRandomQuestion) {
                        Label("ランダム問題", systemImage: "questionmark.circle")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: {
                        isChallengeModeActive.toggle()
                    }) {
                        Label(isChallengeModeActive ? "チャレンジモード: ON" : "チャレンジモード: OFF", 
                              systemImage: isChallengeModeActive ? "star.fill" : "star")
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(isChallengeModeActive ? .orange : .gray)
                }
                .padding()
                
                // Display difficult questions if any exist
                if (!difficultQuestions.isEmpty) {
                    Section {
                        Text("あなたの苦手な問題:")
                            .font(.headline)
                            .padding(.top)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(difficultQuestions.filter { $0.isDifficult }) { diffQuestion in
                                    VStack {
                                        Text("\(diffQuestion.firstNumber) × \(diffQuestion.secondNumber)")
                                            .font(.title3)
                                        Text("Incorrect: \(diffQuestion.incorrectCount)")
                                            .font(.caption)
                                    }
                                    .padding(8)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding()
                }
                
//                Button("苦手問題をデバッグ表示") {
//                    logDifficultQuestions()
//                }
//                .padding()
//                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("九九メーター")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // 親用管理画面へのリンク
                    Button {
                        showParentDashboard()
                    } label: {
                        Label("親用管理画面", systemImage: "person.circle")
                    }
                }
            }
            .onAppear {
                // アプリ起動時にユーザーポイントが存在しなければ作成
                ensureUserPointsExists()
            }
            // PIN認証用シート
            .sheet(isPresented: $showingPINAuth) {
                ParentAccessView(isAuthenticated: $isAuthenticated)
            }
            // 認証成功時に親用管理画面を表示
            .fullScreenCover(isPresented: $isAuthenticated) {
                ParentDashboardView()
            }
        }
    }
    
    // PIN認証関連のステート変数
    @State private var showingPINAuth = false
    @State private var isAuthenticated = false
    
    // 親用管理画面を表示する処理
    private func showParentDashboard() {
        showingPINAuth = true
    }
    
    /// ユーザーポイントが存在することを確認し、なければ作成
    private func ensureUserPointsExists() {
        if userPoints.isEmpty {
            let newPoints = UserPoints()
            modelContext.insert(newPoints)
            try? modelContext.save()
        }
    }
    
    /// 現在の使用可能ポイントを取得
    private func getCurrentPoints() -> Int {
        return userPoints.first?.availablePoints ?? 0
    }

    /// ランダムな掛け算問題を生成する
    private func generateRandomQuestion() {
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
        
        // 正解を含む
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
    private func checkAnswer(selectedAnswer: Int) {
        guard let question = question else { return }
        
        if selectedAnswer == question.answer {
            // 正解の場合
            let isDifficult = isDifficultQuestion(question)
            addPointsForCorrectAnswer(for: question, isDifficult: isDifficult)
            updateCorrectAttempt(for: question)
            
            // 少し待ってから新しい問題を生成
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                generateRandomQuestion()
            }
        } else {
            resultMessage = "不正解。正解は \(question.answer) です。"
            recordIncorrectAnswer(for: question)
            // 少し待ってから新しい問題を生成
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
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
    }
    
    /// 不正解だった問題を記録する
    /// - Parameter question: 不正解だった掛け算問題
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
        }
        
        // 変更を保存
        try? modelContext.save()
    }
    
    /// 問題に正解した記録を更新する
    /// - Parameter question: 正解した掛け算問題
    private func updateCorrectAttempt(for question: MultiplicationQuestion) {
        // この問題が記録に存在する場合、正解回数を更新
        if let existingRecord = findDifficultQuestion(for: question) {
            existingRecord.increaseCorrectCount()
            try? modelContext.save()
        }
    }
    
    /// 指定された問題に対応する苦手問題の記録を検索する
    /// - Parameter question: 検索対象の掛け算問題
    /// - Returns: 対応するDifficultQuestionオブジェクト（存在しない場合はnil）
    private func findDifficultQuestion(for question: MultiplicationQuestion) -> DifficultQuestion? {
        return difficultQuestions.first { $0.identifier == question.identifier }
    }
    
    /// 苦手問題をコンソールにログ出力する
    private func logDifficultQuestions() {
        let questions = DifficultQuestion.getAllDifficultQuestions(context: modelContext)
        print("■ 苦手問題一覧 (計\(questions.count)件)")
        print("==============================")
        
        if questions.isEmpty {
            print("保存されている苦手問題はありません")
            
            // データベースの状態を詳しくデバッグ
            print("ModelContextの状態を確認します...")
            try? modelContext.save()
            print("ModelContextの保存を実行しました")
            
            // テスト用に問題を追加
            print("テスト用に苦手問題を追加します...")
            DifficultQuestion.recordIncorrectAnswer(firstNumber: 7, secondNumber: 8, context: modelContext)
            
            // 再度取得して確認
            let updatedQuestions = DifficultQuestion.getAllDifficultQuestions(context: modelContext)
            print("再確認: 苦手問題一覧 (計\(updatedQuestions.count)件)")
            for (index, question) in updatedQuestions.enumerated() {
                print("\(index + 1). \(question.debugDescription())")
            }
        } else {
            for (index, question) in questions.enumerated() {
                print("\(index + 1). \(question.debugDescription())")
                print("------------------------------")
            }
        }
        
        // ポイント情報も表示
        print("■ ユーザーポイント情報")
        if let points = userPoints.first {
            print("累計獲得ポイント: \(points.totalEarnedPoints)")
            print("使用可能ポイント: \(points.availablePoints)")
            print("最終更新: \(points.lastUpdated)")
            print("苦手問題ボーナス履歴: \(points.difficultQuestionBonuses)")
        } else {
            print("ポイント情報が存在しません")
        }
    }
}

#Preview {
    ContentView()
}

