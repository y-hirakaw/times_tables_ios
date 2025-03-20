import SwiftUI
import SwiftData

// 改善した問題の一覧を表示するビュー
struct ImprovedQuestionsListView: View {
    let difficultQuestions: [DifficultQuestion]
    
    var body: some View {
        let improvedQuestions = DifficultQuestion.getImprovedQuestions(within: 7, questions: difficultQuestions)
        
        if improvedQuestions.isEmpty {
            Text("最近、改善された問題はありません")
                .foregroundStyle(.secondary)
        } else {
            ForEach(improvedQuestions, id: \.id) { question in
                HStack {
                    Text("\(question.firstNumber) × \(question.secondNumber)")
                        .font(.callout)
                    Spacer()
                    Text("正解率: \(Int(100 - question.incorrectPercentage))%")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
                .padding(.vertical, 4)
            }
            
            Text("頑張って \(improvedQuestions.count) 問が改善されました！")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
    }
}

#Preview {
    ImprovedQuestionsListView(difficultQuestions: [])
}
