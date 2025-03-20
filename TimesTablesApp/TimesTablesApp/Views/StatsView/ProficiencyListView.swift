import SwiftUI
import SwiftData

// 習熟度の一覧を表示するビュー
struct ProficiencyListView: View {
    let difficultQuestions: [DifficultQuestion]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 苦手問題の一覧
            if !difficultQuestions.filter({ $0.isDifficult }).isEmpty {
                Text("苦手な問題:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                let difficultOnes = difficultQuestions.filter { $0.isDifficult }
                    .sorted { $0.incorrectPercentage > $1.incorrectPercentage }
                    .prefix(5)
                
                ForEach(Array(difficultOnes), id: \.id) { question in
                    HStack {
                        Text("\(question.firstNumber) × \(question.secondNumber)")
                            .font(.callout)
                        Spacer()
                        Text("不正解率: \(Int(question.incorrectPercentage))%")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    .padding(.vertical, 4)
                }
                
                if difficultOnes.count > 5 {
                    Text("ほか \(difficultQuestions.filter { $0.isDifficult }.count - 5) 問")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            // 最も得意な問題の一覧
            let proficientOnes = difficultQuestions
                .filter { $0.totalAttempts >= 3 && !$0.isDifficult }
                .sorted { $0.incorrectPercentage < $1.incorrectPercentage }
                .prefix(5)
            
            if !proficientOnes.isEmpty {
                Text("得意な問題:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                ForEach(Array(proficientOnes), id: \.id) { question in
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
            }
        }
    }
}

#Preview {
    ProficiencyListView(difficultQuestions: [])
}