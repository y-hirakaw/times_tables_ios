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
    @State private var answer: String = ""
    @State private var resultMessage: String = ""
    @State private var points = Point()
    /// 苦手問題のリストをSwiftDataから取得
    @Query private var difficultQuestions: [DifficultQuestion]
    /// SwiftDataのモデルコンテキスト
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            if let question = question {
                Text(question.question)
                TextField("Answer", text: $answer)
                    .keyboardType(.numberPad)
                Button("Check Answer") {
                    checkAnswer()
                }
                Text(resultMessage)
                    .foregroundColor(resultMessage == "Correct!" ? .green : .red)
                Text("Points: \(points.value)")
            } else {
                Text("Press the button to generate a question")
            }
            Button(action: generateRandomQuestion) {
                Label("Random Question", systemImage: "questionmark.circle")
            }
            
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
        answer = ""
        resultMessage = ""
    }

    /// ユーザーの回答を確認する
    private func checkAnswer() {
        guard let question = question else { return }
        if Int(answer) == question.answer {
            resultMessage = "Correct!"
            points.increment()
            updateCorrectAttempt(for: question)
        } else {
            resultMessage = "Incorrect. Try again."
            recordIncorrectAnswer(for: question)
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
