import SwiftUI
import SwiftData

struct ProficiencyRatioView: View {
    let difficultQuestions: [DifficultQuestion]
    
    var body: some View {
        VStack(spacing: 20) {
            // とくい・にがて比率の円グラフ
            VStack(alignment: .leading, spacing: 15) {
                Text("とくい・にがてな もんだいの わりあい")
                    .font(.headline)
                    .foregroundColor(.indigo)
                    .padding(.leading)
                
                if difficultQuestions.isEmpty {
                    VStack {
                        Image(systemName: "chart.pie")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                            .padding()
                        
                        Text("データがありません")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 250)
                } else {
                    ProficiencyPieChart(difficultQuestions: difficultQuestions)
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
            
            // 一覧表示
            VStack(alignment: .leading, spacing: 15) {
                Text("もんだいの できぐあい")
                    .font(.headline)
                    .foregroundColor(.indigo)
                    .padding(.leading)
                
                if difficultQuestions.isEmpty {
                    VStack {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.5))
                            .padding()
                        
                        Text("まだ こたえたもんだいが ありません")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ProficiencyListView(difficultQuestions: difficultQuestions)
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
    ProficiencyRatioView(difficultQuestions: [])
        .modelContainer(for: [DifficultQuestion.self], inMemory: true)
}