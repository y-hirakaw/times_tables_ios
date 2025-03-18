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

// PINコードの管理クラス
class PINManager {
    private static let pinKey = "parentDashboardPIN"
    private static let service = "com.timestables.app.parentPin"
    
    // KeyChainへのアクセス関数
    private static func saveToKeychain(pin: String) -> Bool {
        guard let data = pin.data(using: .utf8) else { return false }
        
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: pinKey,
            kSecValueData: data,
            kSecAttrSynchronizable: kCFBooleanFalse
        ]
        
        // 既存のデータを削除
        SecItemDelete(query as CFDictionary)
        
        // 新しいデータを保存
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private static func loadFromKeychain() -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: pinKey,
            kSecReturnData: kCFBooleanTrue,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecAttrSynchronizable: kCFBooleanFalse
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data, let pin = String(data: data, encoding: .utf8) {
            return pin
        }
        return nil
    }
    
    // PINが設定されているかチェック
    static func isPINSet() -> Bool {
        return loadFromKeychain() != nil
    }
    
    // PINを設定
    static func setPin(_ pin: String) -> Bool {
        guard pin.count == 4, pin.allSatisfy({ $0.isNumber }) else {
            return false
        }
        
        return saveToKeychain(pin: pin)
    }
    
    // PINを検証
    static func verifyPin(_ pin: String) -> Bool {
        guard let savedPin = loadFromKeychain() else {
            return false
        }
        
        return savedPin == pin
    }
    
    // PINをリセット（デバッグ用）
    static func resetPin() {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: pinKey,
            kSecAttrSynchronizable: kCFBooleanFalse
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

// PIN入力画面
struct PINEntryView: View {
    @Binding var isAuthenticated: Bool
    @State private var pin = ""
    @State private var showError = false
    @State private var attempts = 0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("親用管理画面へのアクセス")
                .font(.title)
                .padding(.top)
            
            Text("PINコードを入力してください")
                .foregroundColor(.secondary)
            
            SecureField("4桁のPINコード", text: $pin)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200)
                .multilineTextAlignment(.center)
                .onChange(of: pin) { _, newValue in
                    // 4桁入力されたら自動的に検証
                    if newValue.count == 4 {
                        verifyPIN()
                    }
                    // 4桁以上入力できないようにする
                    if newValue.count > 4 {
                        pin = String(newValue.prefix(4))
                    }
                }
            
            if showError {
                Text("PINコードが正しくありません")
                    .foregroundColor(.red)
            }
            
            Button("確認") {
                verifyPIN()
            }
            .buttonStyle(.borderedProminent)
            .disabled(pin.count != 4)
            
            Button("キャンセル") {
                dismiss()
            }
            .padding(.top)
        }
        .padding()
    }
    
    private func verifyPIN() {
        if PINManager.verifyPin(pin) {
            isAuthenticated = true
            dismiss()
        } else {
            showError = true
            attempts += 1
            pin = ""
            
            // 5回失敗したら画面を閉じる
            if attempts >= 5 {
                dismiss()
            }
        }
    }
}

// PIN設定画面
struct PINSetupView: View {
    @Binding var isAuthenticated: Bool
    @State private var pin = ""
    @State private var confirmPin = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("親用管理画面のセキュリティ設定")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.top)
            
            Text("4桁のPINコードを設定してください")
                .foregroundColor(.secondary)
            
            SecureField("PINコード (4桁)", text: $pin)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200)
                .multilineTextAlignment(.center)
                .onChange(of: pin) { _, newValue in
                    if newValue.count > 4 {
                        pin = String(newValue.prefix(4))
                    }
                }
            
            SecureField("PINコードの確認", text: $confirmPin)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200)
                .multilineTextAlignment(.center)
                .onChange(of: confirmPin) { _, newValue in
                    if newValue.count > 4 {
                        confirmPin = String(newValue.prefix(4))
                    }
                }
            
            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button("設定") {
                setupPIN()
            }
            .buttonStyle(.borderedProminent)
            .disabled(pin.count != 4 || confirmPin.count != 4)
            
            Button("キャンセル") {
                dismiss()
            }
            .padding(.top)
        }
        .padding()
    }
    
    private func setupPIN() {
        // PINが数字のみか確認
        if !pin.allSatisfy({ $0.isNumber }) {
            showError = true
            errorMessage = "PINコードは数字のみ使用できます"
            return
        }
        
        // 確認用と一致するか確認
        if pin != confirmPin {
            showError = true
            errorMessage = "PINコードが一致しません"
            confirmPin = ""
            return
        }
        
        // PINを設定
        if PINManager.setPin(pin) {
            isAuthenticated = true
            dismiss()
        } else {
            showError = true
            errorMessage = "PINコードは4桁の数字である必要があります"
        }
    }
}

// 親用管理画面へのアクセス確認ビュー
struct ParentAccessView: View {
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        Group {
            if PINManager.isPINSet() {
                PINEntryView(isAuthenticated: $isAuthenticated)
            } else {
                PINSetupView(isAuthenticated: $isAuthenticated)
            }
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
