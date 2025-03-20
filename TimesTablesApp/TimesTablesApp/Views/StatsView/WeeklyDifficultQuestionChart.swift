import SwiftUI
import SwiftData
import Charts

// にがてもんだいの しゅうかんすいいを ひょうじする ぼうグラフ
struct WeeklyDifficultQuestionChart: View {
    let difficultQuestions: [DifficultQuestion]
    @State private var animateChart = false
    
    var body: some View {
        let weeklyData = calculateWeeklyStats()
        
        if weeklyData.isEmpty {
            VStack {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 50))
                    .foregroundColor(.gray.opacity(0.5))
                    .padding()
                
                Text("データが たりません")
                    .foregroundColor(.secondary)
                    .font(.title3)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VStack {
                Chart {
                    ForEach(weeklyData) { dataPoint in
                        BarMark(
                            x: .value("ようび", dataPoint.dayName),
                            y: .value("にがてもんだいすう", dataPoint.difficultCount)
                        )
                        .foregroundStyle(dataPoint.dayName == weeklyData.last?.dayName ? Color.blue.gradient : Color.orange.gradient)
                        .cornerRadius(6)
                        .annotation(position: .top) {
                            Text("\(dataPoint.difficultCount)")
                                .font(.caption.bold())
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.system(.callout, design: .rounded))
                    }
                }
                .chartYAxis {
                    AxisMarks {
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [5, 3]))
                        AxisValueLabel()
                            .font(.system(.caption, design: .rounded))
                    }
                }
                .scaleEffect(y: animateChart ? 1.0 : 0.2)
                .opacity(animateChart ? 1.0 : 0.5)
                .animation(.easeOut(duration: 1.0), value: animateChart)
                .onAppear {
                    animateChart = true
                }
                
                // せんしゅうと くらべた にがてもんだいの ぞうげん
                let currentWeekCount = weeklyData.last?.difficultCount ?? 0
                let firstWeekCount = weeklyData.first?.difficultCount ?? 0
                
                if currentWeekCount != firstWeekCount {
                    HStack(spacing: 12) {
                        if currentWeekCount < firstWeekCount {
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundColor(.green)
                                .font(.title3)
                            
                            Text("にがてもんだいが \(firstWeekCount - currentWeekCount)もん へりました！")
                                .foregroundColor(.green)
                                .font(.callout.bold())
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(
                                    Capsule()
                                        .fill(Color.green.opacity(0.15))
                                )
                        } else {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(.orange)
                                .font(.title3)
                            
                            Text("にがてもんだいが \(currentWeekCount - firstWeekCount)もん ふえています")
                                .foregroundColor(.orange)
                                .font(.callout.bold())
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(
                                    Capsule()
                                        .fill(Color.orange.opacity(0.15))
                                )
                        }
                    }
                    .padding(.top, 12)
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // しゅうかんデータを けいさん
    private func calculateWeeklyStats() -> [WeeklyDataPoint] {
        let calendar = Calendar.current
        
        // きょうの ひづけから 7にちまえまでの データを よういする
        var weeklyData: [WeeklyDataPoint] = []
        
        // にほんごの ようび ひょうじ
        let dayNames = ["にち", "げつ", "か", "すい", "もく", "きん", "ど"]
        
        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else {
                continue
            }
            
            // この ひづけ じてんでの にがてもんだい カウント
            let difficultCount = DifficultQuestion.getDifficultQuestionsCountAt(date: date, questions: difficultQuestions)
            
            // ようびを しゅとく
            let weekday = calendar.component(.weekday, from: date) - 1 // 0 = にちようび
            let dayName = dayNames[weekday]
            
            weeklyData.append(WeeklyDataPoint(day: date, dayName: dayName, difficultCount: difficultCount))
        }
        
        return weeklyData
    }
    
    // グラフようの データこうぞう
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