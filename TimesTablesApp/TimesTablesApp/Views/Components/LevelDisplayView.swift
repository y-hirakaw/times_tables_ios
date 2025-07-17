import SwiftUI

/// レベル情報を表示するコンパクトなUIコンポーネント
struct LevelDisplayView: View {
    @StateObject private var levelSystem = LevelSystemViewState()
    
    var body: some View {
        VStack(spacing: 8) {
            // レベルとアイコン
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.yellow)
                
                Text("Lv.\(levelSystem.currentLevel)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 経験値表示
                Text("\(levelSystem.currentExperience) EXP")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // 称号
            Text(levelSystem.currentTitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 経験値バー
            VStack(spacing: 4) {
                HStack {
                    Text(NSLocalizedString("level_experience", comment: "経験値"))
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(levelSystem.currentExperience) / \(levelSystem.experienceRequiredForNextLevel)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: max(0.0, min(1.0, levelSystem.currentLevelProgress)))
                    .frame(height: 6)
                    .accentColor(.blue)
                
                if levelSystem.experienceToNextLevel > 0 {
                    Text(String(format: NSLocalizedString("level_next_exp", comment: "あと%lldでレベルアップ"), levelSystem.experienceToNextLevel))
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .onAppear {
            levelSystem.fetchUserLevel()
        }
    }
}

/// 詳細なレベル情報を表示するView
struct LevelDetailView: View {
    @StateObject private var levelSystem = LevelSystemViewState()
    
    var body: some View {
        VStack(spacing: 16) {
            // ヘッダー
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString("level_current_level", comment: "現在のレベル"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Text("Lv.\(levelSystem.currentLevel)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Image(systemName: "star.fill")
                            .font(.title2)
                            .foregroundColor(.yellow)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(NSLocalizedString("level_current_title", comment: "現在の称号"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(levelSystem.currentTitle)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
            
            // 経験値プログレス
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(NSLocalizedString("level_experience_progress", comment: "経験値"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(levelSystem.currentExperience) / \(levelSystem.experienceRequiredForNextLevel)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: max(0.0, min(1.0, levelSystem.currentLevelProgress)))
                    .frame(height: 8)
                    .accentColor(.blue)
                
                if levelSystem.experienceToNextLevel > 0 {
                    Text(String(format: NSLocalizedString("level_next_exp_detail", comment: "次のレベルまであと%lldポイント"), levelSystem.experienceToNextLevel))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // レベルアップ履歴
            if !levelSystem.levelUpHistory.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("level_up_history", comment: "レベルアップ履歴"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(Array(levelSystem.levelUpHistory.suffix(5).reversed()), id: \.date) { record in
                                HStack {
                                    Text("Lv.\(record.fromLevel) → Lv.\(record.toLevel)")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    Text(DateFormatter.shortDate.string(from: record.date))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 100)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
        .onAppear {
            levelSystem.fetchUserLevel()
        }
    }
}

/// レベルアップアニメーション表示
struct LevelUpAnimationView: View {
    let levelUpInfo: LevelSystemViewState.LevelUpInfo
    @Binding var isPresented: Bool
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    @State private var rotation: Double = 0.0
    
    var body: some View {
        ZStack {
            // 背景
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // レベルアップアイコン
                Image(systemName: "star.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
                
                // レベルアップメッセージ
                Text(NSLocalizedString("level_up_message", comment: "レベルアップ！"))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(opacity)
                
                // レベル情報
                VStack(spacing: 8) {
                    Text("Lv.\(levelUpInfo.fromLevel) → Lv.\(levelUpInfo.toLevel)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(levelUpInfo.newTitle)
                        .font(.headline)
                        .foregroundColor(.yellow)
                }
                .opacity(opacity)
                
                // 閉じるボタン
                Button(NSLocalizedString("level_up_continue", comment: "続ける")) {
                    isPresented = false
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.blue)
                )
                .foregroundColor(.white)
                .fontWeight(.semibold)
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                rotation = 360.0
            }
        }
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}

// MARK: - Preview

struct LevelDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            LevelDisplayView()
            LevelDetailView()
        }
        .padding()
    }
}