//
//  Achievement.swift
//  TimesTablesApp
//
//  Created by Claude Code on 2025/07/13.
//

import Foundation
import SwiftData

/// 達成の種類を示す列挙型
enum AchievementType: String, CaseIterable, Codable {
    case tableMastery = "table_mastery"           // 段のマスター
    case streakAchievement = "streak_achievement"  // 連続達成
    case speedImprovement = "speed_improvement"    // 速度向上
    case challengeComplete = "challenge_complete"  // チャレンジ完了
    case perfectScore = "perfect_score"           // 満点達成
    case dailyGoal = "daily_goal"                 // 日次目標達成
    case weeklyGoal = "weekly_goal"               // 週次目標達成
    case timeRecord = "time_record"               // 時間記録
    case difficultyOvercome = "difficulty_overcome" // 苦手克服
    
    var displayName: String {
        switch self {
        case .tableMastery:
            return "だんマスター"
        case .streakAchievement:
            return "れんぞくたっせい"
        case .speedImprovement:
            return "はやくなった"
        case .challengeComplete:
            return "チャレンジクリア"
        case .perfectScore:
            return "まんてん"
        case .dailyGoal:
            return "きょうのもくひょう"
        case .weeklyGoal:
            return "しゅうのもくひょう"
        case .timeRecord:
            return "じかんきろく"
        case .difficultyOvercome:
            return "にがてこくふく"
        }
    }
    
    var icon: String {
        switch self {
        case .tableMastery:
            return "crown.fill"
        case .streakAchievement:
            return "flame.fill"
        case .speedImprovement:
            return "bolt.fill"
        case .challengeComplete:
            return "checkmark.circle.fill"
        case .perfectScore:
            return "star.fill"
        case .dailyGoal:
            return "target"
        case .weeklyGoal:
            return "calendar"
        case .timeRecord:
            return "stopwatch.fill"
        case .difficultyOvercome:
            return "heart.fill"
        }
    }
    
    var color: String {
        switch self {
        case .tableMastery:
            return "gold"
        case .streakAchievement:
            return "orange"
        case .speedImprovement:
            return "blue"
        case .challengeComplete:
            return "green"
        case .perfectScore:
            return "yellow"
        case .dailyGoal:
            return "purple"
        case .weeklyGoal:
            return "indigo"
        case .timeRecord:
            return "teal"
        case .difficultyOvercome:
            return "pink"
        }
    }
}

/// 達成・実績を管理するモデル
@Model
class Achievement {
    /// 達成の一意識別子
    var id: UUID
    
    /// 達成の種類
    var type: AchievementType
    
    /// 達成のタイトル
    var title: String
    
    /// 達成の詳細説明
    var achievementDescription: String
    
    /// 達成日時
    var earnedDate: Date
    
    /// 親と共有されたかどうか
    var isShared: Bool
    
    /// 関連するデータ（JSON形式）
    /// 例：段番号、連続日数、改善時間など
    var metadata_Data: Data?
    
    /// メタデータ（計算プロパティ）
    var metadata: [String: String]? {
        get {
            guard let data = metadata_Data else { return nil }
            return try? JSONDecoder().decode([String: String].self, from: data)
        }
        set {
            metadata_Data = try? JSONEncoder().encode(newValue)
        }
    }
    
    /// 特別な達成かどうか（記念すべき達成）
    var isSpecial: Bool
    
    init(
        type: AchievementType,
        title: String,
        achievementDescription: String,
        metadata: [String: String]? = nil,
        isSpecial: Bool = false
    ) {
        self.id = UUID()
        self.type = type
        self.title = title
        self.achievementDescription = achievementDescription
        self.earnedDate = Date()
        self.isShared = false
        self.isSpecial = isSpecial
        self.metadata_Data = nil
        self.metadata = metadata
    }
}

extension Achievement {
    /// 最近の達成一覧を取得
    static func getRecentAchievements(limit: Int = 20, context: ModelContext) -> [Achievement] {
        let descriptor = FetchDescriptor<Achievement>(
            sortBy: [SortDescriptor(\.earnedDate, order: .reverse)]
        )
        
        let achievements = (try? context.fetch(descriptor)) ?? []
        return Array(achievements.prefix(limit))
    }
    
    /// 特定タイプの達成を取得
    static func getAchievements(of type: AchievementType, context: ModelContext) -> [Achievement] {
        let descriptor = FetchDescriptor<Achievement>(
            predicate: #Predicate<Achievement> { achievement in
                achievement.type == type
            },
            sortBy: [SortDescriptor(\.earnedDate, order: .reverse)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    /// 未共有の達成を取得
    static func getUnsharedAchievements(context: ModelContext) -> [Achievement] {
        let descriptor = FetchDescriptor<Achievement>(
            predicate: #Predicate<Achievement> { achievement in
                !achievement.isShared
            },
            sortBy: [SortDescriptor(\.earnedDate, order: .reverse)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    /// 段マスター達成を作成
    static func createTableMasteryAchievement(
        table: Int,
        context: ModelContext
    ) -> Achievement {
        let achievement = Achievement(
            type: .tableMastery,
            title: "\(table)のだん マスター！",
            achievementDescription: "\(table)のだんを かんぺきに おぼえました！",
            metadata: ["table": "\(table)"],
            isSpecial: true
        )
        
        context.insert(achievement)
        try? context.save()
        
        return achievement
    }
    
    /// 連続達成記録を作成
    static func createStreakAchievement(
        streak: Int,
        context: ModelContext
    ) -> Achievement {
        let achievement = Achievement(
            type: .streakAchievement,
            title: "\(streak)にち れんぞく！",
            achievementDescription: "\(streak)にち つづけて がんばりました！",
            metadata: ["streak": "\(streak)"],
            isSpecial: streak >= 7 // 1週間以上は特別
        )
        
        context.insert(achievement)
        try? context.save()
        
        return achievement
    }
    
    /// 速度向上達成を作成
    static func createSpeedImprovementAchievement(
        previousTime: Double,
        newTime: Double,
        context: ModelContext
    ) -> Achievement {
        let improvement = previousTime - newTime
        let improvementPercent = Int((improvement / previousTime) * 100)
        
        let achievement = Achievement(
            type: .speedImprovement,
            title: "はやくなった！",
            achievementDescription: "\(improvementPercent)% はやく こたえられるように なりました！",
            metadata: [
                "previousTime": String(format: "%.1f", previousTime),
                "newTime": String(format: "%.1f", newTime),
                "improvement": "\(improvementPercent)"
            ],
            isSpecial: improvementPercent >= 20
        )
        
        context.insert(achievement)
        try? context.save()
        
        return achievement
    }
    
    /// デイリーチャレンジ達成を作成
    static func createDailyChallengeAchievement(
        targetProblems: Int,
        completedProblems: Int,
        context: ModelContext
    ) -> Achievement {
        let achievement = Achievement(
            type: .challengeComplete,
            title: "きょうのチャレンジ クリア！",
            achievementDescription: "もくひょうの \(targetProblems)もん を たっせいしました！",
            metadata: [
                "target": "\(targetProblems)",
                "completed": "\(completedProblems)"
            ]
        )
        
        context.insert(achievement)
        try? context.save()
        
        return achievement
    }
    
    /// 満点達成を作成
    static func createPerfectScoreAchievement(
        problemCount: Int,
        context: ModelContext
    ) -> Achievement {
        let achievement = Achievement(
            type: .perfectScore,
            title: "まんてん！",
            achievementDescription: "\(problemCount)もん ぜんぶ せいかいしました！",
            metadata: ["problems": "\(problemCount)"],
            isSpecial: problemCount >= 10
        )
        
        context.insert(achievement)
        try? context.save()
        
        return achievement
    }
    
    /// 苦手克服達成を作成
    static func createDifficultyOvercomeAchievement(
        questionId: String,
        previousCorrectRate: Double,
        newCorrectRate: Double,
        context: ModelContext
    ) -> Achievement {
        let improvement = Int((newCorrectRate - previousCorrectRate) * 100)
        
        let achievement = Achievement(
            type: .difficultyOvercome,
            title: "にがて こくふく！",
            achievementDescription: "\(questionId) が とくいに なりました！",
            metadata: [
                "question": questionId,
                "improvement": "\(improvement)"
            ],
            isSpecial: true
        )
        
        context.insert(achievement)
        try? context.save()
        
        return achievement
    }
    
    /// 達成を共有済みにマーク
    func markAsShared(context: ModelContext) {
        isShared = true
        try? context.save()
    }
    
    /// 総達成数を取得
    static func getTotalCount(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<Achievement>()
        return (try? context.fetch(descriptor).count) ?? 0
    }
    
    /// 特別な達成の数を取得
    static func getSpecialCount(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<Achievement>(
            predicate: #Predicate<Achievement> { achievement in
                achievement.isSpecial
            }
        )
        return (try? context.fetch(descriptor).count) ?? 0
    }
    
    /// 今月の達成数を取得
    static func getThisMonthCount(context: ModelContext) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        let descriptor = FetchDescriptor<Achievement>(
            predicate: #Predicate<Achievement> { achievement in
                achievement.earnedDate >= startOfMonth
            }
        )
        return (try? context.fetch(descriptor).count) ?? 0
    }
    
    /// 古い達成を削除（保存期限管理）
    static func cleanupOldAchievements(olderThan months: Int, context: ModelContext) {
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .month, value: -months, to: Date()) ?? Date()
        
        let descriptor = FetchDescriptor<Achievement>(
            predicate: #Predicate<Achievement> { achievement in
                achievement.earnedDate < cutoffDate && !achievement.isSpecial
            }
        )
        
        if let oldAchievements = try? context.fetch(descriptor) {
            for achievement in oldAchievements {
                context.delete(achievement)
            }
            try? context.save()
        }
    }
}