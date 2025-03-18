import SwiftUI
import SwiftData

struct Point {
    var value: Int = 0

    mutating func increment() {
        value += 1
    }
}

struct ContentView: View {
    @State private var question: MultiplicationQuestion? = nil
    @State private var resultMessage: String = ""
    @State private var points = Point()
    @State private var answerChoices: [Int] = []
    /// 苦手問題のリストをSwiftDataから取得
    @Query private var difficultQuestions: [DifficultQuestion]
    /// SwiftDataのモデルコンテキスト
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
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
                    .foregroundColor(resultMessage == "正解！" ? .green : .red)
                    .font(.headline)
                    .padding()
                
                Text("獲得ポイント: \(points.value)")
            } else {
                Text("ボタンを押して問題を表示しよう！")
                    .font(.title)
                    .padding()
            }
            
            Button(action: generateRandomQuestion) {
                Label("ランダム問題", systemImage: "questionmark.circle")
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
            // Display difficult questions if any exist
            if !difficultQuestions.isEmpty {
                Section {
                    Text("Your difficult questions:")
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
            
            Button("苦手問題をデバッグ表示") {
                logDifficultQuestions()
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    /// ランダムな掛け算問題を生成する
    private func generateRandomQuestion() {
        question = MultiplicationQuestion.randomQuestion()
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
            resultMessage = "正解！"
            points.increment()
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
    }
}

#Preview {
    ContentView()
}
