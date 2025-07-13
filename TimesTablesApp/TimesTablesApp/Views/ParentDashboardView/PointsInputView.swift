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
            VStack(spacing: Spacing.spacing24) {
                VStack(alignment: .leading, spacing: Spacing.spacing16) {
                    Text("ポイント消費")
                        .font(.themeTitle2)
                        .foregroundColor(.themePrimaryText)
                    
                    VStack(spacing: Spacing.spacing12) {
                        TextField("消費ポイント", text: $pointsToSpend)
                            .keyboardType(.numberPad)
                            .inputFieldStyle()
                        
                        TextField("理由（おもちゃ交換など）", text: $spendingReason)
                            .inputFieldStyle()
                    }
                }
                
                Spacer()
                
                HStack(spacing: Spacing.spacing16) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .secondaryButtonStyle()
                    
                    Button("実行") {
                        onSubmit()
                        dismiss()
                    }
                    .primaryButtonStyle()
                }
            }
            .padding(Spacing.spacing24)
            .navigationTitle("ポイント消費")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}