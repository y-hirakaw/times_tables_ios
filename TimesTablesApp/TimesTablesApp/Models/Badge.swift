import Foundation
import SwiftData
import SwiftUI

/// バッジの種類を定義する列挙型
enum BadgeType: String, Codable, CaseIterable {
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
                title: "れんぞく10かい",
                description: "10問連続で正解した",
                requirement: "10問連続正解"
            )
        case .streak20:
            return BadgeDisplayInfo(
                icon: "flame.fill",
                color: .red,
                title: "れんぞく20かい",
                description: "20問連続で正解した",
                requirement: "20問連続正解"
            )
        case .streak50:
            return BadgeDisplayInfo(
                icon: "flame.circle.fill",
                color: .purple,
                title: "れんぞくマスター",
                description: "50問連続で正解した",
                requirement: "50問連続正解"
            )
        case .problems100:
            return BadgeDisplayInfo(
                icon: "star.fill",
                color: .blue,
                title: "100もんたっせい",
                description: "100問解いた",
                requirement: "累計100問解答"
            )
        case .problems500:
            return BadgeDisplayInfo(
                icon: "star.circle.fill",
                color: .indigo,
                title: "500もんたっせい",
                description: "500問解いた",
                requirement: "累計500問解答"
            )
        case .problems1000:
            return BadgeDisplayInfo(
                icon: "star.square.fill",
                color: .purple,
                title: "1000もんたっせい",
                description: "1000問解いた",
                requirement: "累計1000問解答"
            )
        case .speedster:
            return BadgeDisplayInfo(
                icon: "hare.fill",
                color: .green,
                title: "はやうちくん",
                description: "3秒以内に10問正解",
                requirement: "3秒以内正解×10"
            )
        case .lightning:
            return BadgeDisplayInfo(
                icon: "bolt.fill",
                color: .yellow,
                title: "いなずまスピード",
                description: "2秒以内に20問正解",
                requirement: "2秒以内正解×20"
            )
        case .overcomer:
            return BadgeDisplayInfo(
                icon: "checkmark.shield.fill",
                color: .mint,
                title: "にがてこくふく",
                description: "苦手問題を5つ克服",
                requirement: "苦手問題5つ克服"
            )
        case .conqueror:
            return BadgeDisplayInfo(
                icon: "trophy.fill",
                color: .orange,
                title: "にがてせいふく",
                description: "苦手問題を10個克服",
                requirement: "苦手問題10個克服"
            )
        case .tableMaster:
            return BadgeDisplayInfo(
                icon: "graduationcap.fill",
                color: .blue,
                title: "だんマスター",
                description: "1つの段をマスター",
                requirement: "1つの段で正解率86%以上"
            )
        case .allTableMaster:
            return BadgeDisplayInfo(
                icon: "crown.fill",
                color: .yellow,
                title: "ぜんだんマスター",
                description: "全ての段をマスター",
                requirement: "全9段で正解率86%以上"
            )
        case .dailyChampion:
            return BadgeDisplayInfo(
                icon: "calendar.badge.checkmark",
                color: .green,
                title: "まいにちチャンピオン",
                description: "7日連続でデイリー目標達成",
                requirement: "7日連続目標達成"
            )
        case .weeklyWarrior:
            return BadgeDisplayInfo(
                icon: "calendar.badge.plus",
                color: .indigo,
                title: "しゅうかんせんし",
                description: "30日連続でデイリー目標達成",
                requirement: "30日連続目標達成"
            )
        case .level10:
            return BadgeDisplayInfo(
                icon: "10.circle.fill",
                color: .blue,
                title: "レベル10",
                description: "レベル10に到達",
                requirement: "レベル10到達"
            )
        case .level25:
            return BadgeDisplayInfo(
                icon: "25.circle.fill",
                color: .purple,
                title: "レベル25",
                description: "レベル25に到達",
                requirement: "レベル25到達"
            )
        case .level50:
            return BadgeDisplayInfo(
                icon: "50.circle.fill",
                color: .orange,
                title: "レベル50",
                description: "レベル50に到達",
                requirement: "レベル50到達"
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

