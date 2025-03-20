import SwiftUI

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
            
            // 警告メッセージの追加
            Text("※PINコードを忘れると管理画面へアクセスできなくなります。\n忘れないようにメモを取るなどの対策をしてください。")
                .font(.footnote)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
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