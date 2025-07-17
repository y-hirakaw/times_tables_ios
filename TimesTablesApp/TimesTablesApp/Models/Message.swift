//
//  Message.swift
//  TimesTablesApp
//
//  Created by Claude Code on 2025/07/13.
//

import Foundation
import SwiftData

/// メッセージの送信者を示す列挙型
enum MessageSender: String, CaseIterable, Codable {
    case child = "child"      // 子供から親へ
    case parent = "parent"    // 親から子供へ
    
    var displayName: String {
        switch self {
        case .child:
            return "こども"
        case .parent:
            return "ほごしゃ"
        }
    }
}

/// メッセージのタイプを示す列挙型
enum MessageType: String, CaseIterable, Codable {
    case text = "text"                    // テキストメッセージ
    case studyReport = "study_report"     // 学習報告
    case achievement = "achievement"      // 達成報告
    
    var displayName: String {
        switch self {
        case .text:
            return "メッセージ"
        case .studyReport:
            return "がんばりほうこく"
        case .achievement:
            return "たっせいほうこく"
        }
    }
}

/// 親子間のメッセージを管理するモデル
@Model
class Message {
    /// メッセージの一意識別子
    var id: UUID
    
    /// 送信者（親or子）
    var sender: MessageSender
    
    /// メッセージのタイプ
    var messageType: MessageType
    
    /// メッセージの内容（テキスト）
    var content: String
    
    
    /// メッセージ送信日時
    var timestamp: Date
    
    /// 既読フラグ
    var isRead: Bool
    
    /// 関連する達成ID（達成報告の場合）
    var achievementId: UUID?
    
    /// 学習セッションに関連するデータ（JSON形式）
    var sessionData_Data: Data?
    
    /// 学習セッションデータ（計算プロパティ）
    var sessionData: StudySessionData? {
        get {
            guard let data = sessionData_Data else { return nil }
            return try? JSONDecoder().decode(StudySessionData.self, from: data)
        }
        set {
            sessionData_Data = try? JSONEncoder().encode(newValue)
        }
    }
    
    init(
        sender: MessageSender,
        messageType: MessageType,
        content: String,
        achievementId: UUID? = nil,
        sessionData: StudySessionData? = nil
    ) {
        self.id = UUID()
        self.sender = sender
        self.messageType = messageType
        self.content = content
        self.timestamp = Date()
        self.isRead = false
        self.achievementId = achievementId
        self.sessionData = sessionData
    }
}

/// 学習セッションのデータ構造
struct StudySessionData: Codable {
    let totalProblems: Int
    let correctAnswers: Int
    let averageTime: Double
    let completedChallenges: [String]
    let newMasteries: [Int] // マスターした段
    let date: Date
    
    var correctRate: Double {
        guard totalProblems > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(totalProblems)
    }
    
    init(
        totalProblems: Int,
        correctAnswers: Int,
        averageTime: Double,
        completedChallenges: [String] = [],
        newMasteries: [Int] = []
    ) {
        self.totalProblems = totalProblems
        self.correctAnswers = correctAnswers
        self.averageTime = averageTime
        self.completedChallenges = completedChallenges
        self.newMasteries = newMasteries
        self.date = Date()
    }
}

extension Message {
    /// 最新のメッセージ一覧を取得
    static func getRecentMessages(limit: Int = 50, context: ModelContext) -> [Message] {
        let descriptor = FetchDescriptor<Message>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        let messages = (try? context.fetch(descriptor)) ?? []
        return Array(messages.prefix(limit))
    }
    
    /// 未読メッセージ数を取得
    static func getUnreadCount(for recipient: MessageSender, context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<Message>(
            predicate: #Predicate<Message> { message in
                message.sender != recipient && !message.isRead
            }
        )
        
        return (try? context.fetch(descriptor).count) ?? 0
    }
    
    /// 特定の送信者のメッセージを取得
    static func getMessages(from sender: MessageSender, context: ModelContext) -> [Message] {
        let descriptor = FetchDescriptor<Message>(
            predicate: #Predicate<Message> { message in
                message.sender == sender
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    /// メッセージを既読にする
    func markAsRead(context: ModelContext) {
        isRead = true
        try? context.save()
    }
    
    /// 全ての未読メッセージを既読にする
    static func markAllAsRead(for recipient: MessageSender, context: ModelContext) {
        let descriptor = FetchDescriptor<Message>(
            predicate: #Predicate<Message> { message in
                message.sender != recipient && !message.isRead
            }
        )
        
        if let messages = try? context.fetch(descriptor) {
            for message in messages {
                message.isRead = true
            }
            try? context.save()
        }
    }
    
    /// 学習報告メッセージを作成
    static func createStudyReport(
        sessionData: StudySessionData,
        context: ModelContext
    ) -> Message {
        let content = generateStudyReportContent(from: sessionData)
        
        let message = Message(
            sender: .child,
            messageType: .studyReport,
            content: content,
            sessionData: sessionData
        )
        
        context.insert(message)
        try? context.save()
        
        return message
    }
    
    /// 達成報告メッセージを作成
    static func createAchievementMessage(
        achievement: String,
        achievementId: UUID? = nil,
        context: ModelContext
    ) -> Message {
        let content = "やったー！\(achievement)ができました！"
        
        let message = Message(
            sender: .child,
            messageType: .achievement,
            content: content,
            achievementId: achievementId
        )
        
        context.insert(message)
        try? context.save()
        
        return message
    }
    
    /// 親からの励ましメッセージを作成
    static func createParentMessage(
        content: String,
        context: ModelContext
    ) -> Message {
        let message = Message(
            sender: .parent,
            messageType: .text,
            content: content
        )
        
        context.insert(message)
        try? context.save()
        
        return message
    }
    
    /// 学習報告の内容を生成
    private static func generateStudyReportContent(from sessionData: StudySessionData) -> String {
        let correctRate = Int(sessionData.correctRate * 100)
        let averageTime = String(format: "%.1f", sessionData.averageTime)
        
        var content = "きょうは \(sessionData.totalProblems)もん といて、\(sessionData.correctAnswers)もん せいかいしました！"
        content += "\nせいかいりつ: \(correctRate)%"
        content += "\nへいきん じかん: \(averageTime)びょう"
        
        if !sessionData.completedChallenges.isEmpty {
            content += "\nクリアしたチャレンジ: \(sessionData.completedChallenges.joined(separator: ", "))"
        }
        
        if !sessionData.newMasteries.isEmpty {
            let masteredTables = sessionData.newMasteries.map { "\($0)のだん" }.joined(separator: ", ")
            content += "\nあたらしくマスターしたもの: \(masteredTables)"
        }
        
        return content
    }
    
    /// メッセージ履歴をクリア（古いメッセージを削除）
    static func cleanupOldMessages(olderThan days: Int, context: ModelContext) {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        let descriptor = FetchDescriptor<Message>(
            predicate: #Predicate<Message> { message in
                message.timestamp < cutoffDate
            }
        )
        
        if let oldMessages = try? context.fetch(descriptor) {
            for message in oldMessages {
                context.delete(message)
            }
            try? context.save()
        }
    }
}