import SwiftUI
import SwiftData
import Charts

struct MultiplicationTableStatsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewState: MultiplicationTableStatsViewState
    
    // 表示する段の数
    private let tableRange = 1...9
    
    // カラーテーマ
    private let correctColor = Color.green.opacity(0.7)
    private let incorrectColor = Color.red.opacity(0.7)
    
    // 共有ModelContainerのヘルパー実装
    private var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DifficultQuestion.self,
            AnswerTimeRecord.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        // ViewStateの初期化
        // 一時的なModelContextを使用して初期化
        let tempContext = ModelContext(sharedModelContainer)
        _viewState = StateObject(wrappedValue: MultiplicationTableStatsViewState(modelContext: tempContext))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("かけ算の だんごとの せいかい・ふせいかい")
                .font(.headline)
                .foregroundColor(.indigo)
                .padding(.horizontal)
            
            // 縦表示に変更
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewState.tableRange, id: \.self) { table in
                        tableStatCard(for: table)
                    }
                }
                .padding(.horizontal)
            }
            
            Divider()
                .padding(.vertical, 5)
            
            Text("だんごとの せいかいりつ")
                .font(.headline)
                .foregroundColor(.indigo)
                .padding(.horizontal)
            
            Chart {
                ForEach(viewState.tableRange, id: \.self) { table in
                    let stats = viewState.getTableStats(table: table)
                    if stats.totalCount > 0 {
                        BarMark(
                            x: .value("段", "\(table)の段"),
                            y: .value("正解率", stats.correctPercentage)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .annotation(position: .top) {
                            Text("\(Int(stats.correctPercentage))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .frame(height: 200)
            .chartYScale(domain: 0...100)
            .chartYAxis {
                AxisMarks(position: .leading, values: [0, 25, 50, 75, 100]) { value in
                    AxisGridLine()
                    AxisValueLabel("\(value.index * 25)%")
                }
            }
            .padding()
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
                .shadow(color: .gray.opacity(0.3), radius: 5)
        )
        .onAppear {
            // modelContextを注入
            viewState.modelContext = modelContext
            viewState.loadData()
        }
    }
    
    // 段ごとの統計カードを表示
    private func tableStatCard(for table: Int) -> some View {
        let stats = viewState.getTableStats(table: table)
        
        return HStack {
            // 段ラベル
            Text("\(table)の だん")
                .font(.headline)
                .foregroundColor(.indigo)
                .frame(width: 80, alignment: .leading)
            
            Spacer()
            
            if stats.totalCount > 0 {
                // 解答数
                VStack(alignment: .center) {
                    Text("といた かず")
                        .font(.caption)
                    Text("\(stats.totalCount)")
                        .font(.body)
                        .bold()
                }
                .frame(width: 70)
                
                Spacer()
                
                // 正解数
                VStack(alignment: .center) {
                    Text("せいかい")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text("\(stats.correctCount)")
                        .font(.body)
                        .bold()
                        .foregroundColor(.green)
                }
                .frame(width: 60)
                
                Spacer()
                
                // 不正解数
                VStack(alignment: .center) {
                    Text("ふせいかい")
                        .font(.caption)
                        .foregroundColor(.red)
                    Text("\(stats.incorrectCount)")
                        .font(.body)
                        .bold()
                        .foregroundColor(.red)
                }
                .frame(width: 60)
                
                Spacer()
                
                // 正解率の円グラフ
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 5)
                        .frame(width: 40, height: 40)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(stats.correctPercentage / 100))
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 40, height: 40)
                    
                    Text("\(Int(stats.correctPercentage))%")
                        .font(.caption2)
                        .bold()
                }
            } else {
                Text("まだ といていません")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.3), radius: 3)
        )
    }
}

#Preview {
    MultiplicationTableStatsView()
        .modelContainer(for: [DifficultQuestion.self, AnswerTimeRecord.self], inMemory: true)
} 