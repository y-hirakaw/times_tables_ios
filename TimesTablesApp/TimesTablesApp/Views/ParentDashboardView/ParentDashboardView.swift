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
    @State private var showingParentMessages = false
    
    var body: some View {
        VStack(spacing: Spacing.spacing16) {
            // ヘッダー
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.themeTitle2)
                        .foregroundColor(.themeGray500)
                }
                
                Spacer()
                
                Text("親用管理画面")
                    .font(.themeLargeTitle)
                    .foregroundColor(.themePrimaryText)
                
                Spacer()
                
                // バランスを取るための空のスペースを確保
                Image(systemName: "xmark.circle.fill")
                    .font(.themeTitle2)
                    .foregroundColor(.clear)
            }
            .padding(Spacing.spacing16)
            
            // ポイント情報
            PointsSummaryView()
            
            // メッセージボタン
            Button(action: {
                showingParentMessages = true
            }) {
                HStack {
                    Image(systemName: "message.circle.fill")
                    Text("お子様とのメッセージ")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, Spacing.spacing16)
            
            // タブ選択
            Picker("履歴タイプ", selection: $selectedTab) {
                Text("獲得履歴").tag(0)
                Text("消費履歴").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, Spacing.spacing16)
            
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
                    .primaryButtonStyle()
            }
            .padding(Spacing.spacing16)
        }
        .padding(Spacing.spacing16)
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
        .sheet(isPresented: $showingParentMessages) {
            ParentMessageView()
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
