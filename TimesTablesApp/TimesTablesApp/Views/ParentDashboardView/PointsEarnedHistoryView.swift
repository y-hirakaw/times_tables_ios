import SwiftUI
import SwiftData

// ポイント獲得履歴表示用のサブビュー
struct PointsEarnedHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var pointsHistory: [PointHistory] = []
    
    var body: some View {
        List {
            if pointsHistory.isEmpty {
                Text("ポイント獲得履歴はありません")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(pointsHistory) { history in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(history.isBonus ? "ボーナスポイント" : "基本ポイント")
                                .font(.headline)
                            Text(formatDate(history.date))
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        Text("+\(history.pointsEarned)")
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .onAppear(perform: loadHistory)
    }
    
    private func loadHistory() {
        let descriptor = FetchDescriptor<PointHistory>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            pointsHistory = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching point history: \(error)")
        }
    }
}

#Preview {
    PointsEarnedHistoryView()
}