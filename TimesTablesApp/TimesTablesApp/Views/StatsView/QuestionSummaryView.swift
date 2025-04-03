import SwiftUI
import SwiftData

struct QuestionSummaryView: View {
    @Query private var answerRecords: [AnswerTimeRecord]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("もんだい かいとう サマリー")
                .font(.headline)
                .foregroundColor(.indigo)
                .padding(.leading)
            
            if answerRecords.isEmpty {
                VStack {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.5))
                        .padding()
                    
                    Text("まだ かいとうした もんだいが ありません")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                VStack(spacing: 20) {
                    // トータル解答数と今週の解答数
                    HStack(spacing: 30) {
                        summaryItem(
                            icon: "number.circle.fill",
                            iconColor: .blue,
                            title: "ぜんぶの もんだいすう",
                            value: "\(answerRecords.count)もん"
                        )
                        
                        summaryItem(
                            icon: "clock.badge.checkmark.fill",
                            iconColor: .green,
                            title: "こんしゅうの もんだいすう",
                            value: "\(getWeeklyQuestionCount())もん"
                        )
                    }
                    
                    // 正解率と平均解答時間
                    HStack(spacing: 30) {
                        summaryItem(
                            icon: "checkmark.circle.fill", 
                            iconColor: .orange,
                            title: "せいかいりつ",
                            value: "\(getCorrectPercentage())%"
                        )
                        
                        summaryItem(
                            icon: "timer", 
                            iconColor: .purple,
                            title: "へいきん じかん",
                            value: formatTime(getAverageAnswerTime())
                        )
                    }
                }
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
    }
    
    // サマリーアイテムの共通レイアウト
    private func summaryItem(icon: String, iconColor: Color, title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(iconColor)
                .padding(.bottom, 2)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(minWidth: 120)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
    }
    
    // 今週の問題解答数を取得
    private func getWeeklyQuestionCount() -> Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        return answerRecords.filter { $0.date >= weekAgo }.count
    }
    
    // 正解率を計算
    private func getCorrectPercentage() -> Int {
        if answerRecords.isEmpty { return 0 }
        
        let correctAnswers = answerRecords.filter { $0.isCorrect }.count
        return Int(Double(correctAnswers) / Double(answerRecords.count) * 100)
    }
    
    // 平均解答時間を計算
    private func getAverageAnswerTime() -> Double {
        if answerRecords.isEmpty { return 0 }
        
        // 時間切れの回答は平均計算から除外
        let validRecords = answerRecords.filter { !$0.isTimeout }
        if validRecords.isEmpty { return 0 }
        
        let totalTime = validRecords.reduce(0.0) { $0 + $1.answerTimeSeconds }
        return totalTime / Double(validRecords.count)
    }
    
    // 時間をフォーマット（秒 -> "X.X びょう"）
    private func formatTime(_ seconds: Double) -> String {
        return String(format: "%.1f びょう", seconds)
    }
}

#Preview {
    QuestionSummaryView()
        .modelContainer(for: [AnswerTimeRecord.self], inMemory: true)
} 