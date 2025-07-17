//
//  ParentMessageView.swift
//  TimesTablesApp
//
//  Created by Claude Code on 2025/07/13.
//

import SwiftUI

/// 親用メッセージ管理ビュー
struct ParentMessageView: View {
    @Environment(\.dataStore) private var dataStore
    @Environment(\.dismiss) private var dismiss
    @State private var communicationViewState = CommunicationViewState()
    @State private var messageText = ""
    @State private var showingTemplates = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // メッセージ一覧
                messagesList
                
                Divider()
                
                // メッセージ入力エリア
                messageInputArea
            }
            .navigationTitle(NSLocalizedString("メッセージ", comment: "Message"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("閉じる", comment: "Close")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("テンプレート", comment: "Template")) {
                        showingTemplates = true
                    }
                }
            }
            .onAppear {
                communicationViewState.setDataStore(dataStore)
                // 親向けメッセージを既読にする
                communicationViewState.markAllMessagesAsRead(for: .parent)
            }
            .sheet(isPresented: $showingTemplates) {
                templateSelectionView
            }
        }
    }
    
    private var messagesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if communicationViewState.messages.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "message.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text(NSLocalizedString("まだメッセージがありません", comment: "No messages yet"))
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(NSLocalizedString("お子様とのコミュニケーションを始めましょう", comment: "Let's start communicating with your child"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 50)
                } else {
                    ForEach(communicationViewState.messages) { message in
                        MessageBubbleView(
                            message: message,
                            isFromParent: message.sender == .parent,
                            communicationViewState: communicationViewState
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    private var messageInputArea: some View {
        VStack(spacing: 12) {
            // テキスト入力
            HStack {
                TextField(NSLocalizedString("メッセージを入力...", comment: "Enter message..."), text: $messageText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(1...4)
                
                Button(action: sendTextMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var templateSelectionView: some View {
        NavigationView {
            List {
                Section(NSLocalizedString("よく使うメッセージ", comment: "Frequently Used Messages")) {
                    ForEach(communicationViewState.getEncouragementTemplates(), id: \.self) { template in
                        Button(action: {
                            communicationViewState.sendQuickReply(template)
                            showingTemplates = false
                        }) {
                            Text(template)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .navigationTitle(NSLocalizedString("テンプレート選択", comment: "Select Template"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("閉じる", comment: "Close")) {
                        showingTemplates = false
                    }
                }
            }
        }
    }
    
    private func sendTextMessage() {
        let content = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        
        communicationViewState.sendTextMessage(content: content, sender: .parent)
        messageText = ""
    }
    
}

/// メッセージバブルビュー
private struct MessageBubbleView: View {
    let message: Message
    let isFromParent: Bool
    let communicationViewState: CommunicationViewState
    
    var body: some View {
        HStack {
            if isFromParent {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: isFromParent ? .trailing : .leading, spacing: 4) {
                // メッセージ内容
                VStack(alignment: .leading, spacing: 8) {
                    // メッセージタイプアイコン
                    if message.messageType != .text {
                        HStack {
                            Image(systemName: iconForMessageType(message.messageType))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(message.messageType.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // メッセージテキスト
                    Text(message.content)
                        .font(.subheadline)
                        .foregroundColor(isFromParent ? .white : .primary)
                    
                    
                    // 学習データ表示
                    if let sessionData = message.sessionData {
                        studyDataView(sessionData)
                    }
                }
                .padding(12)
                .background(
                    isFromParent ? Color.blue : Color(.systemGray5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // タイムスタンプ
                Text(formatTimestamp(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !isFromParent {
                Spacer(minLength: 50)
            }
        }
        .onTapGesture {
            if !message.isRead && !isFromParent {
                communicationViewState.markMessageAsRead(message)
            }
        }
    }
    
    private func studyDataView(_ sessionData: StudySessionData) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Divider()
                .background(isFromParent ? Color.white.opacity(0.3) : Color.gray.opacity(0.3))
            
            HStack {
                Text(NSLocalizedString("問題数: %lld", comment: "Problems: %lld").replacingOccurrences(of: "%lld", with: "\(sessionData.totalProblems)"))
                Spacer()
                Text(NSLocalizedString("正解率: %lld%%", comment: "Accuracy rate: %lld%%").replacingOccurrences(of: "%lld", with: "\(Int(sessionData.correctRate * 100))"))
            }
            .font(.caption)
            .foregroundColor(isFromParent ? .white.opacity(0.8) : .secondary)
            
            if !sessionData.newMasteries.isEmpty {
                Text(NSLocalizedString("新マスター: %@", comment: "New Master: %@").replacingOccurrences(of: "%@", with: sessionData.newMasteries.map { NSLocalizedString("%lldの だん", comment: "%lld times table").replacingOccurrences(of: "%lld", with: "\($0)") }.joined(separator: ", ")))
                    .font(.caption)
                    .foregroundColor(isFromParent ? .white.opacity(0.8) : .secondary)
            }
        }
    }
    
    private func iconForMessageType(_ type: MessageType) -> String {
        switch type {
        case .text:
            return "message"
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
            formatter.dateFormat = "M/d HH:mm"
        }
        
        return formatter.string(from: date)
    }
}

#Preview {
    ParentMessageView()
        .environment(\.dataStore, DataStore.shared)
}