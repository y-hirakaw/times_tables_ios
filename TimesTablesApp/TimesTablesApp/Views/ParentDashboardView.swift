import SwiftUI
import SwiftData

struct ParentDashboardView: View {
    @Query private var userPoints: [UserPoints]
    @Query private var pointHistory: [PointHistory]
    @Query private var pointSpending: [PointSpending]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingPointsInput = false
    @State private var pointsToSpend = ""
    @State private var spendingReason = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            // ヘッダー
            Text("親用管理画面")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            // ポイント情報
            PointsSummaryView()
            
            // タブ選択
            Picker("履歴タイプ", selection: $selectedTab) {
                Text("獲得履歴").tag(0)
                Text("消費履歴").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // 履歴表示エリア
            TabView(selection: $selectedTab) {
                PointsEarnedHistoryView()
                    .tag(0)
                
                PointsSpendingHistoryView()
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            Spacer()
            
            // ポイント消費ボタン
            Button(action: {
                showingPointsInput = true
            }) {
                Label("ポイント消費", systemImage: "minus.circle")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
        .sheet(isPresented: $showingPointsInput) {
            PointsInputView(
                pointsToSpend: $pointsToSpend,
                spendingReason: $spendingReason,
                showingAlert: $showingAlert,
                alertMessage: $alertMessage,
                onSubmit: spendPoints
            )
        }
        .alert("ポイント消費", isPresented: $showingAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
    }
    
    // ポイント消費処理
    private func spendPoints() {
        guard let points = Int(pointsToSpend), points > 0 else {
            alertMessage = "有効なポイント数を入力してください"
            showingAlert = true
            return
        }
        
        guard let userPoint = userPoints.first else {
            alertMessage = "ポイント情報が見つかりません"
            showingAlert = true
            return
        }
        
        if userPoint.spendPoints(points, reason: spendingReason, context: modelContext) {
            alertMessage = "\(points)ポイントを消費しました"
            // 入力欄をクリア
            pointsToSpend = ""
            spendingReason = ""
        } else {
            alertMessage = "ポイントが足りません"
        }
        
        showingAlert = true
    }
}

// ポイント概要表示用のサブビュー
struct PointsSummaryView: View {
    @Query private var userPoints: [UserPoints]
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text("累計獲得ポイント")
                        .font(.headline)
                    Text("\(userPoints.first?.totalEarnedPoints ?? 0)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("使用可能ポイント")
                        .font(.headline)
                    Text("\(userPoints.first?.availablePoints ?? 0)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

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

// ポイント消費入力用のシート
struct PointsInputView: View {
    @Binding var pointsToSpend: String
    @Binding var spendingReason: String
    @Binding var showingAlert: Bool
    @Binding var alertMessage: String
    var onSubmit: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("ポイント消費")) {
                    TextField("消費ポイント", text: $pointsToSpend)
                        .keyboardType(.numberPad)
                    
                    TextField("理由（おもちゃ交換など）", text: $spendingReason)
                }
            }
            .navigationTitle("ポイント消費")
            .navigationBarItems(
                leading: Button("キャンセル") {
                    dismiss()
                },
                trailing: Button("実行") {
                    onSubmit()
                    dismiss()
                }
            )
        }
    }
}

// 日付フォーマット関数
func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter.string(from: date)
}

#Preview {
    ParentDashboardView()
}
