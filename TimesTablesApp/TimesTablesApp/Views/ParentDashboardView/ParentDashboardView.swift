import SwiftUI
import SwiftData

struct ParentDashboardView: View {
    @Query private var userPoints: [UserPoints]
    @Query private var pointHistory: [PointHistory]
    @Query private var pointSpending: [PointSpending]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingPointsInput = false
    @State private var pointsToSpend = ""
    @State private var spendingReason = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            // ヘッダー
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("親用管理画面")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                // バランスを取るための空のスペースを確保
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.clear)
            }
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

#Preview {
    ParentDashboardView()
}
