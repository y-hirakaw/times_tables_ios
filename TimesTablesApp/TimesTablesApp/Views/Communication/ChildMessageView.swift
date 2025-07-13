//
//  ChildMessageView.swift
//  TimesTablesApp
//
//  Created by Claude Code on 2025/07/13.
//

import SwiftUI

/// 子供向けメッセージ受信ビュー
struct ChildMessageView: View {
    @Environment(\.dataStore) private var dataStore
    @Environment(\.dismiss) private var dismiss
    @State private var communicationViewState = CommunicationViewState()
    @State private var showingNewAchievements = false
    
    var parentMessages: [Message] {
        communicationViewState.messages.filter { $0.sender == .parent }
    }
    
    var unsharedAchievements: [Achievement] {
        communicationViewState.recentAchievements.filter { !$0.isShared }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // ヘッダー
                    VStack(spacing: 12) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.pink)
                        
                        Text("ほごしゃからの メッセージ")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if communicationViewState.unreadMessagesForChild > 0 {
                            Text("あたらしいメッセージが \(communicationViewState.unreadMessagesForChild)こ あります")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                    
                    // 新しい達成があれば表示
                    if !unsharedAchievements.isEmpty {
                        achievementsSectionView
                    }
                    
                    // メッセージ一覧
                    messagesSectionView
                }
                .padding()
            }
            .navigationTitle("メッセージ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("とじる") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                communicationViewState.setDataStore(dataStore)
                // 子供向けメッセージを既読にする
                communicationViewState.markAllMessagesAsRead(for: .child)
            }
            .sheet(isPresented: $showingNewAchievements) {
                achievementShareView
            }
        }
    }
    
    private var achievementsSectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("あたらしい たっせい！")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                
                Button("ほごしゃに おしらせ") {
                    showingNewAchievements = true
                }
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .clipShape(Capsule())
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(unsharedAchievements) { achievement in
                        AchievementCardView(achievement: achievement)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var messagesSectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "message.fill")
                    .foregroundColor(.blue)
                Text("メッセージ")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            
            if parentMessages.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "envelope.open")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("まだ メッセージが ありません")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("ほごしゃのひとからの \nメッセージを まってね！")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(parentMessages) { message in
                        ChildMessageBubbleView(
                            message: message,
                            communicationViewState: communicationViewState
                        )
                    }
                }
            }
        }
    }
    
    private var achievementShareView: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)
                    
                    Text("おめでとう！")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("ほごしゃのひとに きょうの たっせいを おしらせしよう！")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(unsharedAchievements) { achievement in
                            Button(action: {
                                communicationViewState.shareAchievement(achievement)
                            }) {
                                AchievementShareCardView(achievement: achievement)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("たっせい シェア")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("とじる") {
                        showingNewAchievements = false
                    }
                }
            }
        }
    }
}

/// 子供向けメッセージバブル
private struct ChildMessageBubbleView: View {
    let message: Message
    let communicationViewState: CommunicationViewState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // メッセージ内容
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    // メッセージタイプ
                    if message.messageType != .text {
                        HStack {
                            Image(systemName: iconForMessageType(message.messageType))
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text(message.messageType.displayName)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // メッセージテキスト
                    Text(message.content)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    // 音声再生ボタン
                    if message.messageType == .audio {
                        Button(action: {
                            communicationViewState.playAudio(from: message)
                        }) {
                            HStack {
                                Image(systemName: communicationViewState.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                Text(communicationViewState.isPlaying ? "ていし" : "きく")
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Capsule())
                        }
                    }
                }
                
                Spacer()
                
                // 親のアイコン
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            // タイムスタンプ
            Text(formatTimestamp(message.timestamp))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func iconForMessageType(_ type: MessageType) -> String {
        switch type {
        case .text:
            return "message"
        case .audio:
            return "speaker.wave.2.fill"
        case .studyReport:
            return "chart.bar.fill"
        case .achievement:
            return "star.fill"
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "M/d"
        }
        
        return formatter.string(from: date)
    }
}

/// 達成カードビュー
private struct AchievementCardView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.type.icon)
                .font(.title2)
                .foregroundColor(colorForType(achievement.type.color))
            
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80, height: 80)
        .padding(8)
        .background(colorForType(achievement.type.color).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func colorForType(_ colorName: String) -> Color {
        switch colorName {
        case "gold": return .yellow
        case "orange": return .orange
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "pink": return .pink
        default: return .blue
        }
    }
}

/// 達成シェアカードビュー
private struct AchievementShareCardView: View {
    let achievement: Achievement
    
    var body: some View {
        HStack {
            Image(systemName: achievement.type.icon)
                .font(.title2)
                .foregroundColor(colorForType(achievement.type.color))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Text(achievement.achievementDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "paperplane.fill")
                .font(.subheadline)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func colorForType(_ colorName: String) -> Color {
        switch colorName {
        case "gold": return .yellow
        case "orange": return .orange
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "pink": return .pink
        default: return .blue
        }
    }
}

#Preview {
    ChildMessageView()
        .environment(\.dataStore, DataStore.shared)
}