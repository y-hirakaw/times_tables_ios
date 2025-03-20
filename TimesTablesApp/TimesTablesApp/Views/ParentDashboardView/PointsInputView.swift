import SwiftUI

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