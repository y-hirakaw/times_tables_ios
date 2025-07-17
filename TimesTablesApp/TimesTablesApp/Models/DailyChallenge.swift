//
//  DailyChallenge.swift
//  TimesTablesApp
//
//  Created by Claude Code on 2025/07/13.
//

import Foundation
import SwiftData

/// 日々の学習チャレンジを管理するモデル
/// デイリーチャレンジ機能で使用
@Model
class DailyChallenge {
    /// チャレンジの日付（YYYY-MM-DD形式で管理）
    var date: Date
    
    /// 目標問題数
    var targetProblems: Int
    
    /// 完了した問題数
    var completedProblems: Int
    
    /// チャレンジが完了したかどうか
    var isCompleted: Bool {
        return completedProblems >= targetProblems
    }
    
    /// 連続達成記録数
    var streakCount: Int
    
    /// チャレンジ作成日時
    var createdAt: Date
    
    /// プログレス率（0.0〜1.0）
    var progress: Double {
        guard targetProblems > 0 else { return 0.0 }
        return min(1.0, max(0.0, Double(completedProblems) / Double(targetProblems)))
    }
    
    init(date: Date, targetProblems: Int, completedProblems: Int = 0, streakCount: Int = 0) {
        self.date = Calendar.current.startOfDay(for: date)
        self.targetProblems = targetProblems
        self.completedProblems = completedProblems
        self.streakCount = streakCount
        self.createdAt = Date()
    }
}

extension DailyChallenge {
    /// 今日のチャレンジを取得（存在しない場合は作成）
    static func getTodaysChallenge(context: ModelContext) -> DailyChallenge {
        let today = Calendar.current.startOfDay(for: Date())
        
        let descriptor = FetchDescriptor<DailyChallenge>(
            predicate: #Predicate<DailyChallenge> { challenge in
                challenge.date == today
            }
        )
        
        if let existingChallenge = try? context.fetch(descriptor).first {
            return existingChallenge
        }
        
        // 昨日のチャレンジを確認して連続記録を計算
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let yesterdayDescriptor = FetchDescriptor<DailyChallenge>(
            predicate: #Predicate<DailyChallenge> { challenge in
                challenge.date == yesterday
            }
        )
        
        let yesterdayChallenge = try? context.fetch(yesterdayDescriptor).first
        let yesterdayStreak = yesterdayChallenge?.streakCount ?? 0
        let newStreak = (yesterdayChallenge?.isCompleted == true) ? yesterdayStreak + 1 : 0
        
        // 新しいチャレンジを作成（目標は5問に設定）
        let newChallenge = DailyChallenge(
            date: today,
            targetProblems: 5,
            streakCount: newStreak
        )
        
        context.insert(newChallenge)
        try? context.save()
        
        return newChallenge
    }
    
    /// チャレンジの進捗を更新
    func updateProgress(additionalProblems: Int, context: ModelContext) {
        completedProblems += additionalProblems
        
        if isCompleted && streakCount == 0 {
            // 初回完了時は連続記録を1に設定
            streakCount = max(streakCount, 1)
        }
        
        try? context.save()
    }
    
    /// 過去7日間のチャレンジ履歴を取得
    static func getWeeklyHistory(context: ModelContext) -> [DailyChallenge] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        
        let descriptor = FetchDescriptor<DailyChallenge>(
            predicate: #Predicate<DailyChallenge> { challenge in
                challenge.date >= sevenDaysAgo
            },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    /// 現在の連続達成記録を取得
    static func getCurrentStreak(context: ModelContext) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        
        var streak = 0
        var currentDate = today
        
        // 今日から遡って連続記録を計算
        while true {
            let descriptor = FetchDescriptor<DailyChallenge>(
                predicate: #Predicate<DailyChallenge> { challenge in
                    challenge.date == currentDate
                }
            )
            
            if let challenge = try? context.fetch(descriptor).first {
                if challenge.isCompleted {
                    streak += 1
                    currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
                } else {
                    break
                }
            } else {
                break
            }
        }
        
        return streak
    }
}