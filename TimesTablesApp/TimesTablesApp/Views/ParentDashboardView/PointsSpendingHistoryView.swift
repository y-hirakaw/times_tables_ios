import SwiftUI
import SwiftData

// ポイント消費履歴表示用のサブビュー
struct PointsSpendingHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var spendingHistory: [PointSpending] = []
    
    var body: some View {
        List {
            if spendingHistory.isEmpty {
                Text("ポイント消費履歴はありません")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(spendingHistory) { spending in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(spending.reason)
                                .font(.headline)
                            Text(formatDate(spending.date))
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        Text("-\(spending.pointsSpent)")
                            .foregroundColor(.red)
                            .fontWeight(.bold)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .onAppear(perform: loadHistory)
    }
    
    private func loadHistory() {
        let descriptor = FetchDescriptor<PointSpending>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            spendingHistory = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching spending history: \(error)")
        }
    }
}