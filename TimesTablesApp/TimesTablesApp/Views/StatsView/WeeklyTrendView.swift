import SwiftUI
import SwiftData

struct WeeklyTrendView: View {
    let difficultQuestions: [DifficultQuestion]
    
    // 改善された問題を取得
    private var improvedQuestions: [DifficultQuestion] {
        DifficultQuestion.getImprovedQuestions(within: 7, questions: difficultQuestions)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 週間推移の棒グラフ
            VStack(alignment: .leading, spacing: 15) {
                Text("にがてもんだいの すうの うごき")
                    .font(.headline)
                    .foregroundColor(.indigo)
                    .padding(.leading)
                
                if difficultQuestions.isEmpty {
                    VStack {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                            .padding()
                        
                        Text("データがありません")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 250)
                } else {
                    WeeklyDifficultQuestionChart(difficultQuestions: difficultQuestions)
                        .frame(height: 250)
                        .padding()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal)
            
            // 改善した苦手問題一覧
            VStack(alignment: .leading, spacing: 15) {
                Text("こんしゅう よくなった もんだい")
                    .font(.headline)
                    .foregroundColor(.indigo)
                    .padding(.leading)
                
                if difficultQuestions.isEmpty || improvedQuestions.isEmpty {
                    VStack {
                        Image(systemName: "arrow.up.heart.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.5))
                            .padding()
                        
                        Text("さいきん よくなった もんだいは ありません")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ImprovedQuestionsListView(difficultQuestions: improvedQuestions)
                        .padding(.horizontal, 4)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal)
        }
    }
}

#Preview {
    WeeklyTrendView(difficultQuestions: [])
        .modelContainer(for: [DifficultQuestion.self], inMemory: true)
}