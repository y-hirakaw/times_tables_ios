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
        colors: [Color.themePrimary.opacity(0.3), Color.themePrimaryLight.opacity(0.2)],
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
                    VStack(spacing: Spacing.spacing20) {
                        // 問題解答のサマリー表示
                        QuestionSummaryView()
                        
                        // グラフタイプ切り替えボタン
                        GraphTypeSelector(selectedChartType: $selectedChartType)
                            .padding(.horizontal, Spacing.spacing16)
                            .padding(.top, Spacing.spacing8)
                        
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
                    .padding(.vertical, Spacing.spacing16)
                }
            }
            .navigationTitle(NSLocalizedString("がくしゅう とうけい", comment: "Learning Statistics"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(NSLocalizedString("がくしゅう とうけい", comment: "Learning Statistics"))
                        .font(.themeTitle3)
                        .foregroundColor(.themePrimary)
                }
            }
        }
    }
}

#Preview {
    StatsView()
        .modelContainer(for: [DifficultQuestion.self], inMemory: true)
}
