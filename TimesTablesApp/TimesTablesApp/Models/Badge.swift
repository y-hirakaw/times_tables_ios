import Foundation
import SwiftData
import SwiftUI

/// バッジの種類を定義する列挙型
enum BadgeType: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }
    // 連続正解系
    case streak10 = "streak_10"
    case streak20 = "streak_20"
    case streak50 = "streak_50"
    
    // 問題数達成系
    case problems100 = "problems_100"
    case problems500 = "problems_500"
    case problems1000 = "problems_1000"
    
    // 速さ系
    case speedster = "speedster"
    case lightning = "lightning"
    
    // 苦手克服系
    case overcomer = "overcomer"
    case conqueror = "conqueror"
    
    // 段マスター系
    case tableMaster = "table_master"
    case allTableMaster = "all_table_master"
    
    // デイリー系
    case dailyChampion = "daily_champion"
    case weeklyWarrior = "weekly_warrior"
    
    // レベル系
    case level10 = "level_10"
    case level25 = "level_25"
    case level50 = "level_50"
    
    /// バッジの表示情報を取得
    func displayInfo() -> BadgeDisplayInfo {
        switch self {
        case .streak10:
            return BadgeDisplayInfo(
                icon: "flame.fill",
                color: .orange,
                title: NSLocalizedString("れんぞく10かい", comment: "10 in a row"),
                description: NSLocalizedString("10問連続で正解した", comment: "Answered 10 questions correctly in a row"),
                requirement: NSLocalizedString("10問連続正解", comment: "10 consecutive correct answers")
            )
        case .streak20:
            return BadgeDisplayInfo(
                icon: "flame.fill",
                color: .red,
                title: NSLocalizedString("れんぞく20かい", comment: "20 in a row"),
                description: NSLocalizedString("20問連続で正解した", comment: "Answered 20 questions correctly in a row"),
                requirement: NSLocalizedString("20問連続正解", comment: "20 consecutive correct answers")
            )
        case .streak50:
            return BadgeDisplayInfo(
                icon: "flame.circle.fill",
                color: .purple,
                title: NSLocalizedString("れんぞくマスター", comment: "Streak Master"),
                description: NSLocalizedString("50問連続で正解した", comment: "Answered 50 questions correctly in a row"),
                requirement: NSLocalizedString("50問連続正解", comment: "50 consecutive correct answers")
            )
        case .problems100:
            return BadgeDisplayInfo(
                icon: "star.fill",
                color: .blue,
                title: NSLocalizedString("100もんたっせい", comment: "100 problems achievement"),
                description: NSLocalizedString("100問解いた", comment: "Solved 100 problems"),
                requirement: NSLocalizedString("累計100問解答", comment: "Total 100 problems answered")
            )
        case .problems500:
            return BadgeDisplayInfo(
                icon: "star.circle.fill",
                color: .indigo,
                title: NSLocalizedString("500もんたっせい", comment: "500 problems achievement"),
                description: NSLocalizedString("500問解いた", comment: "Solved 500 problems"),
                requirement: NSLocalizedString("累計500問解答", comment: "Total 500 problems answered")
            )
        case .problems1000:
            return BadgeDisplayInfo(
                icon: "star.square.fill",
                color: .purple,
                title: NSLocalizedString("1000もんたっせい", comment: "1000 problems achievement"),
                description: NSLocalizedString("1000問解いた", comment: "Solved 1000 problems"),
                requirement: NSLocalizedString("累計1000問解答", comment: "Total 1000 problems answered")
            )
        case .speedster:
            return BadgeDisplayInfo(
                icon: "hare.fill",
                color: .green,
                title: NSLocalizedString("はやうちくん", comment: "Quick Shooter"),
                description: NSLocalizedString("3秒以内に10問正解", comment: "Answered 10 questions correctly within 3 seconds"),
                requirement: NSLocalizedString("3秒以内正解×10", comment: "Correct answers within 3 seconds x10")
            )
        case .lightning:
            return BadgeDisplayInfo(
                icon: "bolt.fill",
                color: .yellow,
                title: NSLocalizedString("いなずまスピード", comment: "Lightning Speed"),
                description: NSLocalizedString("2秒以内に20問正解", comment: "Answered 20 questions correctly within 2 seconds"),
                requirement: NSLocalizedString("2秒以内正解×20", comment: "Correct answers within 2 seconds x20")
            )
        case .overcomer:
            return BadgeDisplayInfo(
                icon: "checkmark.shield.fill",
                color: .mint,
                title: NSLocalizedString("にがてこくふく", comment: "Overcoming Weaknesses"),
                description: NSLocalizedString("苦手問題を5つ克服", comment: "Overcame 5 difficult problems"),
                requirement: NSLocalizedString("苦手問題5つ克服", comment: "Overcome 5 difficult problems")
            )
        case .conqueror:
            return BadgeDisplayInfo(
                icon: "trophy.fill",
                color: .orange,
                title: NSLocalizedString("にがてせいふく", comment: "Conquering Weaknesses"),
                description: NSLocalizedString("苦手問題を10個克服", comment: "Overcame 10 difficult problems"),
                requirement: NSLocalizedString("苦手問題10個克服", comment: "Overcome 10 difficult problems")
            )
        case .tableMaster:
            return BadgeDisplayInfo(
                icon: "graduationcap.fill",
                color: .blue,
                title: NSLocalizedString("だんマスター", comment: "Table Master"),
                description: NSLocalizedString("1つの段をマスター", comment: "Mastered one times table"),
                requirement: NSLocalizedString("1つの段で正解率86%以上", comment: "86% or higher accuracy in one table")
            )
        case .allTableMaster:
            return BadgeDisplayInfo(
                icon: "crown.fill",
                color: .yellow,
                title: NSLocalizedString("ぜんだんマスター", comment: "All Tables Master"),
                description: NSLocalizedString("全ての段をマスター", comment: "Mastered all times tables"),
                requirement: NSLocalizedString("全9段で正解率86%以上", comment: "86% or higher accuracy in all 9 tables")
            )
        case .dailyChampion:
            return BadgeDisplayInfo(
                icon: "calendar.badge.checkmark",
                color: .green,
                title: NSLocalizedString("まいにちチャンピオン", comment: "Daily Champion"),
                description: NSLocalizedString("7日連続でデイリー目標達成", comment: "Achieved daily goal for 7 consecutive days"),
                requirement: NSLocalizedString("7日連続目標達成", comment: "7 consecutive days goal achievement")
            )
        case .weeklyWarrior:
            return BadgeDisplayInfo(
                icon: "calendar.badge.plus",
                color: .indigo,
                title: NSLocalizedString("しゅうかんせんし", comment: "Weekly Warrior"),
                description: NSLocalizedString("30日連続でデイリー目標達成", comment: "Achieved daily goal for 30 consecutive days"),
                requirement: NSLocalizedString("30日連続目標達成", comment: "30 consecutive days goal achievement")
            )
        case .level10:
            return BadgeDisplayInfo(
                icon: "10.circle.fill",
                color: .blue,
                title: NSLocalizedString("レベル10", comment: "Level 10"),
                description: NSLocalizedString("レベル10に到達", comment: "Reached Level 10"),
                requirement: NSLocalizedString("レベル10到達", comment: "Reach Level 10")
            )
        case .level25:
            return BadgeDisplayInfo(
                icon: "25.circle.fill",
                color: .purple,
                title: NSLocalizedString("レベル25", comment: "Level 25"),
                description: NSLocalizedString("レベル25に到達", comment: "Reached Level 25"),
                requirement: NSLocalizedString("レベル25到達", comment: "Reach Level 25")
            )
        case .level50:
            return BadgeDisplayInfo(
                icon: "50.circle.fill",
                color: .orange,
                title: NSLocalizedString("レベル50", comment: "Level 50"),
                description: NSLocalizedString("レベル50に到達", comment: "Reached Level 50"),
                requirement: NSLocalizedString("レベル50到達", comment: "Reach Level 50")
            )
        }
    }
}

/// バッジの表示情報
struct BadgeDisplayInfo {
    let icon: String
    let color: Color
    let title: String
    let description: String
    let requirement: String
}

/// 獲得したバッジを管理するモデル
@Model
final class UserBadge {
    /// バッジの種類
    var badgeType: String  // BadgeType.rawValue
    
    /// 獲得日時
    var earnedDate: Date
    
    /// 新規バッジかどうか（未表示フラグ）
    var isNew: Bool
    
    /// 作成日時
    var createdAt: Date
    
    init(badgeType: BadgeType, earnedDate: Date = Date()) {
        self.badgeType = badgeType.rawValue
        self.earnedDate = earnedDate
        self.isNew = true
        self.createdAt = Date()
    }
    
    /// バッジタイプを取得
    var type: BadgeType? {
        BadgeType(rawValue: badgeType)
    }
}

