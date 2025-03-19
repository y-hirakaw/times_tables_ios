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

// 得意・苦手の比率を表示する円グラフ
struct ProficiencyPieChart: View {
    let difficultQuestions: [DifficultQuestion]
    
    var body: some View {
        let (proficientCount, difficultCount, undeterminedCount) = calculateProficiencyStats()
        
        Chart {
            SectorMark(
                angle: .value("問題数", proficientCount),
                innerRadius: .ratio(0.5),
                angularInset: 1.5
            )
            .foregroundStyle(Color.green)
            .annotation(position: .overlay) {
                if proficientCount > 0 {
                    Text("\(proficientCount)")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
            
            SectorMark(
                angle: .value("問題数", difficultCount),
                innerRadius: .ratio(0.5),
                angularInset: 1.5
            )
            .foregroundStyle(Color.red)
            .annotation(position: .overlay) {
                if difficultCount > 0 {
                    Text("\(difficultCount)")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
            
            SectorMark(
                angle: .value("問題数", undeterminedCount),
                innerRadius: .ratio(0.5),
                angularInset: 1.5
            )
            .foregroundStyle(Color.gray)
            .annotation(position: .overlay) {
                if undeterminedCount > 0 {
                    Text("\(undeterminedCount)")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
        }
        .chartLegend(position: .bottom, alignment: .center, spacing: 20) {
            HStack(spacing: 20) {
                Label("得意: \(proficientCount)", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(Color.green)
                Label("苦手: \(difficultCount)", systemImage: "xmark.circle.fill")
                    .foregroundStyle(Color.red)
                Label("未判定: \(undeterminedCount)", systemImage: "circle.fill")
                    .foregroundStyle(Color.gray)
            }
        }
    }
    
    // 得意・苦手・未判定の問題数を計算
    private func calculateProficiencyStats() -> (proficient: Int, difficult: Int, undetermined: Int) {
        // 九九の問題は全部で81問あるが、1×1から9×9の81問中、意味のある問題は1×1から9×9の計81問
        let totalPossibleQuestions = 81
        
        // 回答済みの問題の内、苦手でないものは「得意」とみなす
        let difficultCount = difficultQuestions.filter { $0.isDifficult }.count
        
        // 回答済みだが苦手判定に至らない問題（回答数3未満または正解率70%以上）
        let notDifficultCount = difficultQuestions.filter { !$0.isDifficult }.count
        
        // まだ回答していない問題
        let undeterminedCount = totalPossibleQuestions - difficultQuestions.count
        
        return (notDifficultCount, difficultCount, undeterminedCount)
    }
}

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

// 苦手問題の週間推移を表示する棒グラフ
struct WeeklyDifficultQuestionChart: View {
    let difficultQuestions: [DifficultQuestion]
    
    var body: some View {
        let weeklyData = calculateWeeklyStats()
        
        if weeklyData.isEmpty {
            Text("データが不足しています")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Chart {
                ForEach(weeklyData) { dataPoint in
                    BarMark(
                        x: .value("曜日", dataPoint.dayName),
                        y: .value("苦手問題数", dataPoint.difficultCount)
                    )
                    .foregroundStyle(Color.orange.gradient)
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                }
            }
            .chartYAxis {
                AxisMarks {
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            
            // 先週と比較した苦手問題の増減
            let currentWeekCount = weeklyData.last?.difficultCount ?? 0
            let firstWeekCount = weeklyData.first?.difficultCount ?? 0
            
            if currentWeekCount != firstWeekCount {
                HStack {
                    if currentWeekCount < firstWeekCount {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.green)
                        Text("苦手問題が\(firstWeekCount - currentWeekCount)問減りました！")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.orange)
                        Text("苦手問題が\(currentWeekCount - firstWeekCount)問増えています")
                            .foregroundColor(.orange)
                    }
                }
                .font(.callout)
                .padding(.top)
            }
        }
    }
    
    // 週間データを計算
    private func calculateWeeklyStats() -> [WeeklyDataPoint] {
        let calendar = Calendar.current
        
        // 今日の日付から7日前までのデータを用意
        var weeklyData: [WeeklyDataPoint] = []
        
        // 日本語の曜日表示
        let dayNames = ["日", "月", "火", "水", "木", "金", "土"]
        
        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else {
                continue
            }
            
            // この日付時点での苦手問題カウント
            let difficultCount = DifficultQuestion.getDifficultQuestionsCountAt(date: date, questions: difficultQuestions)
            
            // 曜日を取得
            let weekday = calendar.component(.weekday, from: date) - 1 // 0 = 日曜日
            let dayName = dayNames[weekday]
            
            weeklyData.append(WeeklyDataPoint(day: date, dayName: dayName, difficultCount: difficultCount))
        }
        
        return weeklyData
    }
    
    // グラフ用のデータ構造
    struct WeeklyDataPoint: Identifiable {
        let id = UUID()
        let day: Date
        let dayName: String
        let difficultCount: Int
    }
}

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
    StatsView()
        .modelContainer(for: [DifficultQuestion.self], inMemory: true)
}
