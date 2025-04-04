import SwiftUI
import SwiftData

/// ポイント履歴を表示するView
struct PointHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PointHistory.date, order: .reverse) private var pointsHistory: [PointHistory]
    
    var body: some View {
        List {
            if pointsHistory.isEmpty {
                Text("ポイントりれきはありません")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(pointsHistory) { history in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(history.isBonus ? "ボーナスポイント" : "基本ポイント")
                                .font(.headline)
                                .foregroundColor(history.isBonus ? .orange : .blue)
                            
                            Text(formatPointHistoryDate(history.date))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if let questionId = history.questionId {
                                let questionParts = questionId.split(separator: "x")
                                if questionParts.count == 2, 
                                   let first = Int(questionParts[0]),
                                   let second = Int(questionParts[1]) {
                                    Text("\(first) × \(second) のもんだい")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Text("+\(history.pointsEarned)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
    
    /// 日付フォーマット関数
    private func formatPointHistoryDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

#Preview {
    PointHistoryView()
} 