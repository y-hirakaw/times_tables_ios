import SwiftUI
import SwiftData
import Charts

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

#Preview {
    WeeklyDifficultQuestionChart(difficultQuestions: [])
        .frame(height: 300)
        .padding()
}