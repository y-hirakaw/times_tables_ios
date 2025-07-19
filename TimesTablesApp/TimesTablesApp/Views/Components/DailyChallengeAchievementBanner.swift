import SwiftUI

/// デイリーチャレンジ達成時の控えめなバナー通知
struct DailyChallengeAchievementBanner: View {
    @State private var isVisible = true
    
    var body: some View {
        if isVisible {
            HStack(spacing: Spacing.spacing12) {
                // お祝いアイコン
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 20, weight: .bold))
                
                VStack(alignment: .leading, spacing: Spacing.spacing4) {
                    Text("デイリーチャレンジ達成！")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("今日の目標をクリアしました")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // 経験値ボーナス表示
                Text("+5 EXP")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.yellow)
                    .padding(.horizontal, Spacing.spacing8)
                    .padding(.vertical, Spacing.spacing4)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.small)
                            .fill(Color.yellow.opacity(0.2))
                    )
            }
            .padding(.horizontal, Spacing.spacing16)
            .padding(.vertical, Spacing.spacing12)
            .background(
                LinearGradient(
                    colors: [.green, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            .transition(.asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .move(edge: .top).combined(with: .opacity)
            ))
            .onAppear {
                // 3秒後に自動で非表示
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isVisible = false
                    }
                }
            }
        }
    }
}

#Preview {
    VStack {
        DailyChallengeAchievementBanner()
        Spacer()
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}