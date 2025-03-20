import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var difficultQuestions: [DifficultQuestion]
    
    // 現在表示中のグラフタイプ
    @State private var selectedChartType = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // グラフタイプ切り替えセグメントコントロール
                    Picker("グラフタイプ", selection: $selectedChartType) {
                        Text("得意・苦手比率").tag(0)
                        Text("苦手問題の推移").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    if selectedChartType == 0 {
                        // 得意・苦手比率の円グラフ
                        VStack {
                            Text("得意・苦手問題の割合")
                                .font(.headline)
                                .padding(.bottom, 8)
                            
                            if difficultQuestions.isEmpty {
                                Text("データがありません")
                                    .foregroundColor(.secondary)
                                    .frame(height: 300)
                            } else {
                                ProficiencyPieChart(difficultQuestions: difficultQuestions)
                                    .frame(height: 300)
                                    .padding()
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // 一覧表示
                        VStack(alignment: .leading) {
                            Text("問題の習熟度")
                                .font(.headline)
                                .padding(.bottom, 8)
                            
                            if difficultQuestions.isEmpty {
                                Text("まだ解答データがありません")
                                    .foregroundColor(.secondary)
                            } else {
                                ProficiencyListView(difficultQuestions: difficultQuestions)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    } else {
                        // 週間推移の棒グラフ
                        VStack {
                            Text("苦手問題数の週間推移")
                                .font(.headline)
                                .padding(.bottom, 8)
                            
                            WeeklyDifficultQuestionChart(difficultQuestions: difficultQuestions)
                                .frame(height: 300)
                                .padding()
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // 改善した苦手問題一覧
                        VStack(alignment: .leading) {
                            Text("今週改善した問題")
                                .font(.headline)
                                .padding(.bottom, 8)
                            
                            ImprovedQuestionsListView(difficultQuestions: difficultQuestions)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("学習統計")
        }
    }
}

#Preview {
    StatsView()
        .modelContainer(for: [DifficultQuestion.self], inMemory: true)
}
