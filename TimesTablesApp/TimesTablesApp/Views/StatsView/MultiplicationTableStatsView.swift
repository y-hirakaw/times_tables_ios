import SwiftUI
import SwiftData
import Charts

struct MultiplicationTableStatsView: View {
    @Query private var answerRecords: [AnswerTimeRecord]
    @Query private var difficultQuestions: [DifficultQuestion]
    
    // 表示する段の数
    private let tableRange = 1...9
    
    // カラーテーマ
    private let correctColor = Color.green.opacity(0.7)
    private let incorrectColor = Color.red.opacity(0.7)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("かけ算の だんごとの せいかい・ふせいかい")
                .font(.headline)
                .foregroundColor(.indigo)
                .padding(.horizontal)
            
            // 縦表示に変更
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(tableRange, id: \.self) { table in
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
                ForEach(tableRange, id: \.self) { table in
                    let stats = getTableStats(table: table)
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
            // デバッグ情報：データの数を確認
            print("DifficultQuestions: \(difficultQuestions.count)")
            for question in difficultQuestions {
                print("問題: \(question.identifier), 正解数: \(question.correctCount), 不正解数: \(question.incorrectCount)")
            }
        }
    }
    
    // 段ごとの統計カードを表示
    private func tableStatCard(for table: Int) -> some View {
        let stats = getTableStats(table: table)
        
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
    
    // 段ごとの統計情報を取得
    private func getTableStats(table: Int) -> (totalCount: Int, correctCount: Int, incorrectCount: Int, correctPercentage: Double) {
        var totalCorrect = 0
        var totalIncorrect = 0
        
        // 段に関連するすべての問題を見つける - 全てのデータを走査してカウント
        for question in difficultQuestions {
            // この段の問題のみをフィルタリング
            if question.firstNumber == table || question.secondNumber == table {
                totalCorrect += question.correctCount
                totalIncorrect += question.incorrectCount
            }
        }
        
        let totalCount = totalCorrect + totalIncorrect
        
        var correctPercentage: Double = 0
        if totalCount > 0 {
            correctPercentage = Double(totalCorrect) / Double(totalCount) * 100
        }
        
        return (
            totalCount: totalCount,
            correctCount: totalCorrect,
            incorrectCount: totalIncorrect,
            correctPercentage: correctPercentage
        )
    }
}

#Preview {
    MultiplicationTableStatsView()
        .modelContainer(for: [DifficultQuestion.self, AnswerTimeRecord.self], inMemory: true)
} 