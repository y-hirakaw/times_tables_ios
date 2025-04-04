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
                        // 問題解答のサマリー表示
                        QuestionSummaryView()
                        
                        // グラフタイプ切り替えボタン
                        GraphTypeSelector(selectedChartType: $selectedChartType)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        if selectedChartType == 0 {
                            // とくい・にがて比率のビュー
                            ProficiencyRatioView(difficultQuestions: difficultQuestions)
                        } else if selectedChartType == 1 {
                            // 週間推移のビュー
                            WeeklyTrendView(difficultQuestions: difficultQuestions)
                        } else {
                            // 段ごとの解答状況ビュー
                            MultiplicationTableStatsView()
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

#Preview {
    StatsView()
        .modelContainer(for: [DifficultQuestion.self], inMemory: true)
}
