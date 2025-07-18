import SwiftUI

/// バッジ一覧を表示するView
struct BadgeCollectionView: View {
    @StateObject private var badgeSystem = BadgeSystemViewState()
    @State private var selectedBadge: BadgeType?
    @State private var showingDetail = false
    
    let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // ヘッダー
                headerView
                
                // バッジグリッド
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(BadgeType.allCases, id: \.self) { badgeType in
                        BadgeItemView(
                            badgeType: badgeType,
                            isEarned: badgeSystem.earnedBadges.contains { $0.badgeType == badgeType.rawValue },
                            isNew: badgeSystem.newBadges.contains { $0.badgeType == badgeType.rawValue }
                        )
                        .onTapGesture {
                            selectedBadge = badgeType
                            showingDetail = true
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("バッジコレクション")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            badgeSystem.fetchEarnedBadges()
        }
        .sheet(isPresented: $showingDetail) {
            if let badge = selectedBadge {
                BadgeDetailView(badgeType: badge, isEarned: badgeSystem.earnedBadges.contains { $0.badgeType == badge.rawValue })
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("\(badgeSystem.earnedBadgeCount) / \(badgeSystem.totalBadgeCount)")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("バッジかくとく")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ProgressView(value: badgeSystem.progressPercentage / 100)
                .frame(height: 8)
                .padding(.horizontal, 40)
                .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
        .padding(.horizontal)
    }
}

/// 個別のバッジアイテム表示
struct BadgeItemView: View {
    let badgeType: BadgeType
    let isEarned: Bool
    let isNew: Bool
    
    private var displayInfo: BadgeDisplayInfo {
        badgeType.displayInfo()
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // バッジアイコン
                Image(systemName: displayInfo.icon)
                    .font(.system(size: 36))
                    .foregroundColor(isEarned ? displayInfo.color : Color.gray.opacity(0.3))
                
                // NEW表示
                if isNew {
                    Image(systemName: "sparkle")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.yellow)
                        .offset(x: 20, y: -20)
                }
            }
            .frame(width: 60, height: 60)
            .background(
                Circle()
                    .fill(isEarned ? Color(.systemBackground) : Color.gray.opacity(0.1))
                    .shadow(color: isEarned ? displayInfo.color.opacity(0.3) : .clear, radius: 4)
            )
            
            Text(displayInfo.title)
                .font(.caption2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(isEarned ? .primary : .secondary)
                .lineLimit(2)
                .frame(height: 30)
        }
        .opacity(isEarned ? 1.0 : 0.5)
    }
}

/// バッジ詳細表示View
struct BadgeDetailView: View {
    let badgeType: BadgeType
    let isEarned: Bool
    @Environment(\.dismiss) private var dismiss
    
    private var displayInfo: BadgeDisplayInfo {
        badgeType.displayInfo()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // バッジアイコン
                Image(systemName: displayInfo.icon)
                    .font(.system(size: 80))
                    .foregroundColor(isEarned ? displayInfo.color : Color.gray.opacity(0.3))
                    .padding()
                    .background(
                        Circle()
                            .fill(Color(.systemBackground))
                            .shadow(color: isEarned ? displayInfo.color.opacity(0.3) : .clear, radius: 8)
                    )
                
                // バッジ名
                Text(displayInfo.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                // 説明文
                Text(displayInfo.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // 獲得条件
                VStack(spacing: 8) {
                    Text("かくとくじょうけん")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(displayInfo.requirement)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(isEarned ? displayInfo.color : .secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal)
                
                // ステータス
                if isEarned {
                    Label("かくとくずみ！", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundColor(.green)
                } else {
                    Label("みかくとく", systemImage: "lock.fill")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.top, 40)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("とじる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// バッジ獲得通知View
struct BadgeNotificationView: View {
    let badgeType: BadgeType
    @Binding var isPresented: Bool
    
    private var displayInfo: BadgeDisplayInfo {
        badgeType.displayInfo()
    }
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    @State private var rotation: Double = 0.0
    
    var body: some View {
        VStack(spacing: 16) {
            Text("バッジかくとく！")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Image(systemName: displayInfo.icon)
                .font(.system(size: 60))
                .foregroundColor(displayInfo.color)
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
            
            Text(displayInfo.title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(displayInfo.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(displayInfo.color, lineWidth: 3)
        )
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                rotation = 360.0
            }
            
            // 自動的に閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeIn(duration: 0.3)) {
                    opacity = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isPresented = false
                }
            }
        }
    }
}

// MARK: - Preview
struct BadgeDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BadgeCollectionView()
        }
    }
}