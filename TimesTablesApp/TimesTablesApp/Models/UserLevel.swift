import Foundation
import SwiftData

/// ユーザーのレベル情報を管理するモデル
@Model
final class UserLevel {
    /// 現在のレベル（1〜50）
    var currentLevel: Int
    
    /// 現在のレベルでの経験値
    var currentExperience: Int
    
    /// 総獲得経験値（totalEarnedPointsと同期）
    var totalExperience: Int
    
    /// 現在の称号
    var currentTitle: String
    
    /// レベルアップ日時の履歴
    var levelUpHistory: [LevelUpRecord]
    
    /// 作成日時
    var createdAt: Date
    
    /// 最終更新日時
    var lastUpdated: Date
    
    init() {
        self.currentLevel = 1
        self.currentExperience = 0
        self.totalExperience = 0
        self.currentTitle = NSLocalizedString("level_title_beginner", tableName: "Gamification", comment: "九九みならい")
        self.levelUpHistory = []
        self.createdAt = Date()
        self.lastUpdated = Date()
    }
    
    /// レベルアップ記録
    struct LevelUpRecord: Codable {
        let fromLevel: Int
        let toLevel: Int
        let date: Date
        let totalExperienceAtTime: Int
    }
    
    /// 現在のレベルに必要な経験値
    var experienceRequiredForCurrentLevel: Int {
        UserLevel.experienceRequiredForLevel(currentLevel)
    }
    
    /// 次のレベルに必要な経験値
    var experienceRequiredForNextLevel: Int {
        UserLevel.experienceRequiredForLevel(currentLevel + 1)
    }
    
    /// 現在のレベルでの進捗率（0.0〜1.0）
    var currentLevelProgress: Double {
        let currentLevelExp = experienceRequiredForCurrentLevel
        let nextLevelExp = experienceRequiredForNextLevel
        let expInCurrentLevel = totalExperience - currentLevelExp
        let expNeededForLevel = nextLevelExp - currentLevelExp
        
        if expNeededForLevel <= 0 { return 1.0 }
        return min(1.0, max(0.0, Double(expInCurrentLevel) / Double(expNeededForLevel)))
    }
    
    /// 次のレベルまでに必要な経験値
    var experienceToNextLevel: Int {
        max(0, experienceRequiredForNextLevel - totalExperience)
    }
    
    /// レベルに応じた称号を取得
    func getTitleForLevel(_ level: Int) -> String {
        switch level {
        case 1...5:
            return NSLocalizedString("level_title_beginner", tableName: "Gamification", comment: "九九みならい")
        case 6...10:
            return NSLocalizedString("level_title_apprentice", tableName: "Gamification", comment: "九九れんしゅうせい")
        case 11...20:
            return NSLocalizedString("level_title_practitioner", tableName: "Gamification", comment: "九九じゅくれんしゃ")
        case 21...30:
            return NSLocalizedString("level_title_expert", tableName: "Gamification", comment: "九九めいじん")
        case 31...40:
            return NSLocalizedString("level_title_master", tableName: "Gamification", comment: "九九マスター")
        case 41...49:
            return NSLocalizedString("level_title_grandmaster", tableName: "Gamification", comment: "九九グランドマスター")
        case 50:
            return NSLocalizedString("level_title_legend", tableName: "Gamification", comment: "九九レジェンド")
        default:
            return NSLocalizedString("level_title_beginner", tableName: "Gamification", comment: "九九みならい")
        }
    }
    
    /// 経験値を更新し、必要に応じてレベルアップ
    func updateExperience(_ newTotalExperience: Int) -> (didLevelUp: Bool, newLevel: Int?) {
        self.totalExperience = newTotalExperience
        self.lastUpdated = Date()
        
        // 現在の経験値から適切なレベルを計算
        let calculatedLevel = UserLevel.calculateLevelFromExperience(totalExperience)
        
        if calculatedLevel > currentLevel {
            // レベルアップ！
            let previousLevel = currentLevel
            currentLevel = calculatedLevel
            currentTitle = getTitleForLevel(currentLevel)
            
            // レベルアップ履歴を記録
            let record = LevelUpRecord(
                fromLevel: previousLevel,
                toLevel: currentLevel,
                date: Date(),
                totalExperienceAtTime: totalExperience
            )
            levelUpHistory.append(record)
            
            return (true, currentLevel)
        }
        
        return (false, nil)
    }
    
    /// 経験値からレベルを計算
    static func calculateLevelFromExperience(_ experience: Int) -> Int {
        var level = 1
        var requiredExp = 0
        
        while level < 50 {
            requiredExp = experienceRequiredForLevel(level + 1)
            if experience < requiredExp {
                break
            }
            level += 1
        }
        
        return level
    }
    
    /// 特定のレベルに必要な累積経験値を計算
    /// レベル1: 0 EXP
    /// レベル2: 10 EXP
    /// レベル3: 25 EXP
    /// レベル4: 45 EXP
    /// ...
    /// 緩やかな二次曲線で増加
    static func experienceRequiredForLevel(_ level: Int) -> Int {
        guard level > 1 else { return 0 }
        
        // 基本式: 5 * level^2 + 5 * level - 10
        // これにより、レベル50で約13,000の経験値が必要
        let exp = 5 * level * level + 5 * level - 10
        return exp
    }
}