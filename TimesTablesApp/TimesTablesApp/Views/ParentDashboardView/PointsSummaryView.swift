import SwiftUI
import SwiftData

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

#Preview {
    PointsSummaryView()
}