import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var difficultQuestions: [DifficultQuestion]
    
    // 現在表示中のグラフタイプ
    @State private var selectedChartType = 0
    
    // カラーテーマ
    private let gradientBackground = LinearGradient(
        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景グラデーション
                gradientBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // グラフタイプ切り替えボタン
                        GraphTypeSelector(selectedChartType: $selectedChartType)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        if selectedChartType == 0 {
                            // とくい・にがて比率のビュー
                            ProficiencyRatioView(difficultQuestions: difficultQuestions)
                        } else {
                            // 週間推移のビュー
                            WeeklyTrendView(difficultQuestions: difficultQuestions)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("がくしゅう とうけい")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("がくしゅう とうけい")
                        .font(.headline)
                        .foregroundColor(.indigo)
                }
            }
        }
    }
}

// グラフタイプ選択用のコンポーネント
struct GraphTypeSelector: View {
    @Binding var selectedChartType: Int
    
    var body: some View {
        HStack(spacing: 15) {
            Button {
                selectedChartType = 0
            } label: {
                VStack {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 24))
                    Text("とくい・にがて")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(selectedChartType == 0 ? Color.blue.opacity(0.8) : Color.white.opacity(0.8))
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                .foregroundColor(selectedChartType == 0 ? .white : .blue)
            }
            
            Button {
                selectedChartType = 1
            } label: {
                VStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 24))
                    Text("にがての すうじ")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(selectedChartType == 1 ? Color.blue.opacity(0.8) : Color.white.opacity(0.8))
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                .foregroundColor(selectedChartType == 1 ? .white : .blue)
            }
        }
    }
}

// とくい・にがて比率のビューコンポーネント
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

// 週間推移のビューコンポーネント
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
    StatsView()
        .modelContainer(for: [DifficultQuestion.self], inMemory: true)
}
