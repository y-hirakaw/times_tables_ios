# データモデル定義 詳細仕様書

## 1. 新機能用 SwiftData モデル定義

### 1.1 キャラクター進化＆ルームカスタマイズ関連

```swift
import SwiftData
import Foundation

// MARK: - キャラクター進化システム

@Model
class StarterCharacter {
    @Attribute(.unique) var id: UUID
    var characterType: CharacterType
    var currentLevel: Int
    var evolutionStage: Int
    var isSpecialVariant: Bool  // レア個体フラグ
    var nickname: String?
    var obtainedDate: Date
    var lastInteractionDate: Date
    var totalExperience: Int
    var mood: CharacterMood
    var favoriteRoomItems: [String]  // お気に入りアイテムID配列
    
    // リレーション
    @Relationship(deleteRule: .cascade) var room: CharacterRoom?
    
    init(
        id: UUID = UUID(),
        characterType: CharacterType,
        currentLevel: Int = 1,
        evolutionStage: Int = 1,
        isSpecialVariant: Bool = false,
        nickname: String? = nil,
        obtainedDate: Date = Date(),
        lastInteractionDate: Date = Date(),
        totalExperience: Int = 0,
        mood: CharacterMood = .neutral
    ) {
        self.id = id
        self.characterType = characterType
        self.currentLevel = currentLevel
        self.evolutionStage = evolutionStage
        self.isSpecialVariant = isSpecialVariant
        self.nickname = nickname
        self.obtainedDate = obtainedDate
        self.lastInteractionDate = lastInteractionDate
        self.totalExperience = totalExperience
        self.mood = mood
        self.favoriteRoomItems = []
    }
}

enum CharacterType: String, Codable, CaseIterable {
    case tree = "tree"      // くくのき
    case star = "star"      // すうじぼし
    case robot = "robot"    // けいさんロボ
    
    var displayName: String {
        switch self {
        case .tree: return NSLocalizedString("character_tree", comment: "くくのき")
        case .star: return NSLocalizedString("character_star", comment: "すうじぼし")
        case .robot: return NSLocalizedString("character_robot", comment: "けいさんロボ")
        }
    }
}

enum CharacterMood: String, Codable, CaseIterable {
    case happy = "happy"
    case neutral = "neutral"
    case sad = "sad"
    case excited = "excited"
    case sleepy = "sleepy"
    
    var displayName: String {
        switch self {
        case .happy: return NSLocalizedString("mood_happy", comment: "うれしい")
        case .neutral: return NSLocalizedString("mood_neutral", comment: "ふつう")
        case .sad: return NSLocalizedString("mood_sad", comment: "かなしい")
        case .excited: return NSLocalizedString("mood_excited", comment: "わくわく")
        case .sleepy: return NSLocalizedString("mood_sleepy", comment: "ねむい")
        }
    }
}

@Model
class CharacterRoom {
    @Attribute(.unique) var id: UUID
    var floorType: String?
    var wallpaperType: String?
    var roomTheme: String?
    var lastUpdated: Date
    var bonusMultiplier: Double  // ルームボーナス倍率
    
    // リレーション
    @Relationship(deleteRule: .cascade) var furniture: [RoomItem] = []
    @Relationship(deleteRule: .cascade) var decorations: [RoomItem] = []
    @Relationship(inverse: \StarterCharacter.room) var character: StarterCharacter?
    
    init(
        id: UUID = UUID(),
        floorType: String? = nil,
        wallpaperType: String? = nil,
        roomTheme: String? = nil,
        lastUpdated: Date = Date(),
        bonusMultiplier: Double = 1.0
    ) {
        self.id = id
        self.floorType = floorType
        self.wallpaperType = wallpaperType
        self.roomTheme = roomTheme
        self.lastUpdated = lastUpdated
        self.bonusMultiplier = bonusMultiplier
    }
}

@Model
class RoomItem {
    @Attribute(.unique) var id: UUID
    var itemId: String  // RoomItemDatabase での ID
    var positionX: Double?
    var positionY: Double?
    var rotation: Double
    var scale: Double
    var isHidden: Bool
    var purchaseDate: Date
    var interactionCount: Int
    
    init(
        id: UUID = UUID(),
        itemId: String,
        positionX: Double? = nil,
        positionY: Double? = nil,
        rotation: Double = 0.0,
        scale: Double = 1.0,
        isHidden: Bool = false,
        purchaseDate: Date = Date(),
        interactionCount: Int = 0
    ) {
        self.id = id
        self.itemId = itemId
        self.positionX = positionX
        self.positionY = positionY
        self.rotation = rotation
        self.scale = scale
        self.isHidden = isHidden
        self.purchaseDate = purchaseDate
        self.interactionCount = interactionCount
    }
}

@Model
class CharacterInteraction {
    @Attribute(.unique) var id: UUID
    var characterId: UUID
    var interactionType: InteractionType
    var timestamp: Date
    var duration: TimeInterval
    var roomItemId: String?
    var moodBefore: CharacterMood
    var moodAfter: CharacterMood
    
    init(
        id: UUID = UUID(),
        characterId: UUID,
        interactionType: InteractionType,
        timestamp: Date = Date(),
        duration: TimeInterval = 0,
        roomItemId: String? = nil,
        moodBefore: CharacterMood,
        moodAfter: CharacterMood
    ) {
        self.id = id
        self.characterId = characterId
        self.interactionType = interactionType
        self.timestamp = timestamp
        self.duration = duration
        self.roomItemId = roomItemId
        self.moodBefore = moodBefore
        self.moodAfter = moodAfter
    }
}

enum InteractionType: String, Codable, CaseIterable {
    case walk = "walk"
    case sit = "sit"
    case read = "read"
    case watch = "watch"
    case play = "play"
    case study = "study"
    case sleep = "sleep"
    case eat = "eat"
    case dance = "dance"
    
    var displayName: String {
        switch self {
        case .walk: return NSLocalizedString("interaction_walk", comment: "あるく")
        case .sit: return NSLocalizedString("interaction_sit", comment: "すわる")
        case .read: return NSLocalizedString("interaction_read", comment: "よむ")
        case .watch: return NSLocalizedString("interaction_watch", comment: "みる")
        case .play: return NSLocalizedString("interaction_play", comment: "あそぶ")
        case .study: return NSLocalizedString("interaction_study", comment: "べんきょう")
        case .sleep: return NSLocalizedString("interaction_sleep", comment: "ねる")
        case .eat: return NSLocalizedString("interaction_eat", comment: "たべる")
        case .dance: return NSLocalizedString("interaction_dance", comment: "おどる")
        }
    }
}
```

### 1.2 カードガチャシステム関連

```swift
// MARK: - カードガチャシステム

@Model
class CollectionCard {
    @Attribute(.unique) var id: UUID
    var cardDataId: String  // CardDatabase での ID
    var obtainedDate: Date
    var obtainedCount: Int
    var obtainedMethod: ObtainMethod
    var isFavorite: Bool
    var isNew: Bool  // 新規取得フラグ
    var lastViewedDate: Date?
    
    init(
        id: UUID = UUID(),
        cardDataId: String,
        obtainedDate: Date = Date(),
        obtainedCount: Int = 1,
        obtainedMethod: ObtainMethod,
        isFavorite: Bool = false,
        isNew: Bool = true,
        lastViewedDate: Date? = nil
    ) {
        self.id = id
        self.cardDataId = cardDataId
        self.obtainedDate = obtainedDate
        self.obtainedCount = obtainedCount
        self.obtainedMethod = obtainedMethod
        self.isFavorite = isFavorite
        self.isNew = isNew
        self.lastViewedDate = lastViewedDate
    }
}

enum ObtainMethod: String, Codable {
    case gacha = "gacha"
    case reward = "reward"
    case achievement = "achievement"
    case pity = "pity"
    case special = "special"
    case rankingReward = "ranking_reward"
    case completionReward = "completion_reward"
    
    var displayName: String {
        switch self {
        case .gacha: return NSLocalizedString("obtain_gacha", comment: "ガチャ")
        case .reward: return NSLocalizedString("obtain_reward", comment: "報酬")
        case .achievement: return NSLocalizedString("obtain_achievement", comment: "達成")
        case .pity: return NSLocalizedString("obtain_pity", comment: "天井")
        case .special: return NSLocalizedString("obtain_special", comment: "特別")
        case .rankingReward: return NSLocalizedString("obtain_ranking", comment: "ランキング")
        case .completionReward: return NSLocalizedString("obtain_completion", comment: "コンプリート")
        }
    }
}

@Model
class GachaCollection {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var totalGachaCount: Int
    var normalGachaCount: Int
    var premiumGachaCount: Int
    var tenPullGachaCount: Int
    var limitedGachaCount: Int
    var legendaryPityCounter: Int
    var lastGachaDate: Date?
    var totalPointsSpent: Int
    var favoriteCardIds: [String]  // お気に入りカードID配列
    
    // リレーション
    @Relationship(deleteRule: .cascade) var ownedCards: [CollectionCard] = []
    @Relationship(deleteRule: .cascade) var gachaHistory: [GachaRecord] = []
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        totalGachaCount: Int = 0,
        normalGachaCount: Int = 0,
        premiumGachaCount: Int = 0,
        tenPullGachaCount: Int = 0,
        limitedGachaCount: Int = 0,
        legendaryPityCounter: Int = 0,
        lastGachaDate: Date? = nil,
        totalPointsSpent: Int = 0
    ) {
        self.id = id
        self.userId = userId
        self.totalGachaCount = totalGachaCount
        self.normalGachaCount = normalGachaCount
        self.premiumGachaCount = premiumGachaCount
        self.tenPullGachaCount = tenPullGachaCount
        self.limitedGachaCount = limitedGachaCount
        self.legendaryPityCounter = legendaryPityCounter
        self.lastGachaDate = lastGachaDate
        self.totalPointsSpent = totalPointsSpent
        self.favoriteCardIds = []
    }
}

@Model
class GachaRecord {
    @Attribute(.unique) var id: UUID
    var gachaType: GachaType
    var executedDate: Date
    var pointsSpent: Int
    var cardsObtained: [String]  // カードID配列
    var hasLegendary: Bool
    var hasSuperRare: Bool
    var hasNew: Bool
    var pityTriggered: Bool
    
    init(
        id: UUID = UUID(),
        gachaType: GachaType,
        executedDate: Date = Date(),
        pointsSpent: Int,
        cardsObtained: [String],
        hasLegendary: Bool = false,
        hasSuperRare: Bool = false,
        hasNew: Bool = false,
        pityTriggered: Bool = false
    ) {
        self.id = id
        self.gachaType = gachaType
        self.executedDate = executedDate
        self.pointsSpent = pointsSpent
        self.cardsObtained = cardsObtained
        self.hasLegendary = hasLegendary
        self.hasSuperRare = hasSuperRare
        self.hasNew = hasNew
        self.pityTriggered = pityTriggered
    }
}

enum GachaType: String, Codable, CaseIterable {
    case normal = "normal"
    case premium = "premium"
    case tenPull = "ten_pull"
    case limited = "limited"
    case free = "free"
    
    var displayName: String {
        switch self {
        case .normal: return NSLocalizedString("normal_gacha", comment: "つうじょうガチャ")
        case .premium: return NSLocalizedString("premium_gacha", comment: "プレミアムガチャ")
        case .tenPull: return NSLocalizedString("ten_pull_gacha", comment: "10れんガチャ")
        case .limited: return NSLocalizedString("limited_gacha", comment: "げんていガチャ")
        case .free: return NSLocalizedString("free_gacha", comment: "むりょうガチャ")
        }
    }
}

@Model
class CardCollection {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var totalCardsOwned: Int
    var uniqueCardsOwned: Int
    var completionRate: Double
    var lastUpdated: Date
    
    // 段別コレクション進捗
    var table1Progress: Double = 0.0
    var table2Progress: Double = 0.0
    var table3Progress: Double = 0.0
    var table4Progress: Double = 0.0
    var table5Progress: Double = 0.0
    var table6Progress: Double = 0.0
    var table7Progress: Double = 0.0
    var table8Progress: Double = 0.0
    var table9Progress: Double = 0.0
    
    // レアリティ別コレクション進捗
    var normalCardsOwned: Int = 0
    var rareCardsOwned: Int = 0
    var superRareCardsOwned: Int = 0
    var legendaryCardsOwned: Int = 0
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        totalCardsOwned: Int = 0,
        uniqueCardsOwned: Int = 0,
        completionRate: Double = 0.0,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.totalCardsOwned = totalCardsOwned
        self.uniqueCardsOwned = uniqueCardsOwned
        self.completionRate = completionRate
        self.lastUpdated = lastUpdated
    }
}
```

### 1.3 月次ランキングシステム関連

```swift
// MARK: - 月次ランキングシステム

@Model
class MonthlyRanking {
    @Attribute(.unique) var id: UUID
    var year: Int
    var month: Int
    var rankingType: RankingType
    var lastUpdated: Date
    var totalParticipants: Int
    var isFinalized: Bool
    var cutoffDate: Date  // ランキング集計の締切日
    
    // リレーション
    @Relationship(deleteRule: .cascade) var entries: [RankingEntry] = []
    
    init(
        id: UUID = UUID(),
        year: Int,
        month: Int,
        rankingType: RankingType,
        lastUpdated: Date = Date(),
        totalParticipants: Int = 0,
        isFinalized: Bool = false,
        cutoffDate: Date
    ) {
        self.id = id
        self.year = year
        self.month = month
        self.rankingType = rankingType
        self.lastUpdated = lastUpdated
        self.totalParticipants = totalParticipants
        self.isFinalized = isFinalized
        self.cutoffDate = cutoffDate
    }
}

@Model
class RankingEntry {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var userName: String
    var grade: Int?
    var prefecture: String?
    var city: String?
    var rank: Int
    var score: Int
    var previousRank: Int?
    var rankChange: RankChangeType
    var lastActive: Date
    var avatar: UserAvatarData
    var privacyLevel: PrivacyLevel
    
    // リレーション
    @Relationship(deleteRule: .cascade) var badges: [Badge] = []
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        userName: String,
        grade: Int? = nil,
        prefecture: String? = nil,
        city: String? = nil,
        rank: Int,
        score: Int,
        previousRank: Int? = nil,
        rankChange: RankChangeType = .new,
        lastActive: Date = Date(),
        avatar: UserAvatarData,
        privacyLevel: PrivacyLevel = .limitedInfo
    ) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.grade = grade
        self.prefecture = prefecture
        self.city = city
        self.rank = rank
        self.score = score
        self.previousRank = previousRank
        self.rankChange = rankChange
        self.lastActive = lastActive
        self.avatar = avatar
        self.privacyLevel = privacyLevel
    }
}

enum RankingType: String, Codable, CaseIterable {
    case monthlyPoints = "monthly_points"
    case monthlyProblems = "monthly_problems"
    case monthlyAccuracy = "monthly_accuracy"
    case table1Master = "table_1_master"
    case table2Master = "table_2_master"
    case table3Master = "table_3_master"
    case table4Master = "table_4_master"
    case table5Master = "table_5_master"
    case table6Master = "table_6_master"
    case table7Master = "table_7_master"
    case table8Master = "table_8_master"
    case table9Master = "table_9_master"
    case grade1 = "grade_1"
    case grade2 = "grade_2"
    case grade3 = "grade_3"
    case grade4Plus = "grade_4_plus"
    case challengeStreak = "challenge_streak"
    case loginStreak = "login_streak"
    case difficultConquer = "difficult_conquer"
    case speedMaster = "speed_master"
    case prefectureRanking = "prefecture"
    case cityRanking = "city"
}

enum RankChangeType: String, Codable {
    case new = "new"
    case up = "up"
    case down = "down"
    case same = "same"
}

enum PrivacyLevel: Int, Codable, CaseIterable {
    case full = 0
    case limitedInfo = 1
    case avatarOnly = 2
    case anonymous = 3
}

@Model
class UserAvatarData: Codable {
    var characterType: CharacterType
    var backgroundColor: String  // Color の文字列表現
    var accessories: [String]    // アクセサリーID配列
    var evolutionStage: Int
    
    init(
        characterType: CharacterType = .robot,
        backgroundColor: String = "blue",
        accessories: [String] = [],
        evolutionStage: Int = 1
    ) {
        self.characterType = characterType
        self.backgroundColor = backgroundColor
        self.accessories = accessories
        self.evolutionStage = evolutionStage
    }
}

@Model
class MonthlyUserStats {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var year: Int
    var month: Int
    var totalProblems: Int
    var correctProblems: Int
    var totalPointsEarned: Int
    var accuracy: Double
    var challengeParticipationDays: Int
    var loginDays: Int
    var difficultProblemsAttempted: Int
    var difficultProblemsConquered: Int
    var fastAnswersCount: Int
    var maxChallengeStreak: Int
    var maxLoginStreak: Int
    var averageAnswerTime: Double
    var perfectDays: Int  // 100%正解の日数
    var studyTimeMinutes: Int  // 学習時間（分）
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        year: Int,
        month: Int,
        totalProblems: Int = 0,
        correctProblems: Int = 0,
        totalPointsEarned: Int = 0,
        accuracy: Double = 0.0,
        challengeParticipationDays: Int = 0,
        loginDays: Int = 0,
        difficultProblemsAttempted: Int = 0,
        difficultProblemsConquered: Int = 0,
        fastAnswersCount: Int = 0,
        maxChallengeStreak: Int = 0,
        maxLoginStreak: Int = 0,
        averageAnswerTime: Double = 0.0,
        perfectDays: Int = 0,
        studyTimeMinutes: Int = 0
    ) {
        self.id = id
        self.userId = userId
        self.year = year
        self.month = month
        self.totalProblems = totalProblems
        self.correctProblems = correctProblems
        self.totalPointsEarned = totalPointsEarned
        self.accuracy = accuracy
        self.challengeParticipationDays = challengeParticipationDays
        self.loginDays = loginDays
        self.difficultProblemsAttempted = difficultProblemsAttempted
        self.difficultProblemsConquered = difficultProblemsConquered
        self.fastAnswersCount = fastAnswersCount
        self.maxChallengeStreak = maxChallengeStreak
        self.maxLoginStreak = maxLoginStreak
        self.averageAnswerTime = averageAnswerTime
        self.perfectDays = perfectDays
        self.studyTimeMinutes = studyTimeMinutes
    }
}

@Model
class TableMonthlyStats {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var year: Int
    var month: Int
    var table: Int
    var totalProblems: Int
    var correctAnswers: Int
    var accuracy: Double
    var averageTime: Double
    var bestTime: Double
    var worstTime: Double
    var consecutiveCorrect: Int
    var maxConsecutiveCorrect: Int
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        year: Int,
        month: Int,
        table: Int,
        totalProblems: Int = 0,
        correctAnswers: Int = 0,
        accuracy: Double = 0.0,
        averageTime: Double = 0.0,
        bestTime: Double = Double.infinity,
        worstTime: Double = 0.0,
        consecutiveCorrect: Int = 0,
        maxConsecutiveCorrect: Int = 0
    ) {
        self.id = id
        self.userId = userId
        self.year = year
        self.month = month
        self.table = table
        self.totalProblems = totalProblems
        self.correctAnswers = correctAnswers
        self.accuracy = accuracy
        self.averageTime = averageTime
        self.bestTime = bestTime
        self.worstTime = worstTime
        self.consecutiveCorrect = consecutiveCorrect
        self.maxConsecutiveCorrect = maxConsecutiveCorrect
    }
}

@Model
class UserReward {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var rewardType: RewardType
    var rankingType: RankingType?
    var rank: Int?
    var year: Int
    var month: Int
    var points: Int
    var gachaTickets: Int
    var title: String?
    var receivedDate: Date
    var isReceived: Bool
    var specialCardIds: [String]  // 特別カードID配列
    
    // リレーション
    @Relationship(deleteRule: .cascade) var badges: [Badge] = []
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        rewardType: RewardType,
        rankingType: RankingType? = nil,
        rank: Int? = nil,
        year: Int,
        month: Int,
        points: Int = 0,
        gachaTickets: Int = 0,
        title: String? = nil,
        receivedDate: Date = Date(),
        isReceived: Bool = false
    ) {
        self.id = id
        self.userId = userId
        self.rewardType = rewardType
        self.rankingType = rankingType
        self.rank = rank
        self.year = year
        self.month = month
        self.points = points
        self.gachaTickets = gachaTickets
        self.title = title
        self.receivedDate = receivedDate
        self.isReceived = isReceived
        self.specialCardIds = []
    }
}

enum RewardType: String, Codable {
    case rankingReward = "ranking"
    case participationReward = "participation"
    case completionReward = "completion"
    case specialEvent = "special_event"
    case milestone = "milestone"
}
```

### 1.4 統合的な新機能統計

```swift
// MARK: - 新機能統計・分析

@Model
class NewFeatureUsageStats {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var year: Int
    var month: Int
    
    // キャラクター進化関連
    var characterInteractionCount: Int = 0
    var roomCustomizationCount: Int = 0
    var roomItemsPurchased: Int = 0
    var characterMoodChanges: Int = 0
    var evolutionCount: Int = 0
    var roomVisitDuration: TimeInterval = 0
    
    // カードガチャ関連
    var totalGachaExecutions: Int = 0
    var pointsSpentOnGacha: Int = 0
    var newCardsObtained: Int = 0
    var legendaryCardsObtained: Int = 0
    var cardCollectionViewTime: TimeInterval = 0
    var favoriteCardsSet: Int = 0
    
    // ランキング関連
    var rankingViewCount: Int = 0
    var rankingParticipations: Int = 0
    var bestRankAchieved: Int?
    var rewardsReceived: Int = 0
    var rankingScreenTime: TimeInterval = 0
    
    // 学習効果への影響
    var learningMotivationScore: Double = 0.0  // 1-10スケール
    var sessionLengthIncrease: Double = 0.0    // 前月比の増加率
    var accuracyImprovement: Double = 0.0      // 前月比の改善率
    var engagementScore: Double = 0.0          // 総合エンゲージメントスコア
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        year: Int,
        month: Int
    ) {
        self.id = id
        self.userId = userId
        self.year = year
        self.month = month
    }
}

@Model
class FeatureAdoptionMetrics {
    @Attribute(.unique) var id: UUID
    var year: Int
    var month: Int
    
    // 全体統計
    var totalActiveUsers: Int = 0
    
    // 機能別採用率
    var characterSystemUsers: Int = 0       // キャラクターシステム利用者
    var roomCustomizationUsers: Int = 0     // ルームカスタマイズ利用者
    var gachaSystemUsers: Int = 0          // ガチャシステム利用者
    var rankingParticipants: Int = 0       // ランキング参加者
    
    // 機能別エンゲージメント
    var avgCharacterInteractionsPerUser: Double = 0.0
    var avgGachaExecutionsPerUser: Double = 0.0
    var avgRankingViewsPerUser: Double = 0.0
    var avgRoomVisitTimePerUser: TimeInterval = 0
    
    // 収益指標（将来的な課金対応時）
    var pointConsumptionRate: Double = 0.0     // ポイント消費率
    var gachaConversionRate: Double = 0.0      // ガチャ利用率
    var retentionRate7Day: Double = 0.0        // 7日継続率
    var retentionRate30Day: Double = 0.0       // 30日継続率
    
    init(
        id: UUID = UUID(),
        year: Int,
        month: Int
    ) {
        self.id = id
        self.year = year
        self.month = month
    }
}

@Model
class LearningEffectAnalysis {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var analysisDate: Date
    var periodType: AnalysisPeriod
    
    // 学習指標（新機能導入前後比較）
    var problemSolvedBeforeFeatures: Int = 0
    var problemSolvedAfterFeatures: Int = 0
    var accuracyBeforeFeatures: Double = 0.0
    var accuracyAfterFeatures: Double = 0.0
    var avgSessionTimeBeforeFeatures: TimeInterval = 0
    var avgSessionTimeAfterFeatures: TimeInterval = 0
    
    // モチベーション指標
    var dailyChallengeCompletionRate: Double = 0.0
    var consecutiveLearningDays: Int = 0
    var difficultProblemAttemptRate: Double = 0.0
    var overallEngagementScore: Double = 0.0
    
    // 新機能の学習効果への貢献度
    var characterMotivationContribution: Double = 0.0
    var gachaRewardContribution: Double = 0.0
    var rankingCompetitionContribution: Double = 0.0
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        analysisDate: Date = Date(),
        periodType: AnalysisPeriod
    ) {
        self.id = id
        self.userId = userId
        self.analysisDate = analysisDate
        self.periodType = periodType
    }
}

enum AnalysisPeriod: String, Codable {
    case weekly = "weekly"
    case monthly = "monthly"
    case quarterly = "quarterly"
}
```

## 2. データ移行・互換性仕様

### 2.1 既存データとの統合

```swift
// MARK: - データ移行とスキーマ更新

class NewFeatureDataMigration {
    
    /// 既存ユーザーに新機能用初期データを設定
    static func initializeNewFeaturesForExistingUsers() {
        let existingUsers = DataStore.shared.getAllUsers()
        
        for user in existingUsers {
            // 1. デフォルトキャラクター設定
            initializeDefaultCharacter(for: user)
            
            // 2. 空のガチャコレクション作成
            initializeGachaCollection(for: user)
            
            // 3. 月次統計データ初期化
            initializeMonthlyStats(for: user)
            
            // 4. 新機能使用統計初期化
            initializeUsageStats(for: user)
        }
    }
    
    private static func initializeDefaultCharacter(for user: User) {
        // ユーザーレベルに基づいてキャラクター初期設定
        let currentLevel = DataStore.shared.getUserLevel(userId: user.id)?.currentLevel ?? 1
        
        let defaultCharacter = StarterCharacter(
            characterType: .robot, // デフォルトはロボット
            currentLevel: currentLevel,
            evolutionStage: CharacterEvolutionManager.getEvolutionStage(for: .robot, level: currentLevel),
            obtainedDate: user.createdAt
        )
        
        let defaultRoom = CharacterRoom()
        defaultCharacter.room = defaultRoom
        
        DataStore.shared.saveCharacter(defaultCharacter)
    }
    
    private static func initializeGachaCollection(for user: User) {
        let collection = GachaCollection(userId: user.id)
        DataStore.shared.saveGachaCollection(collection)
        
        // レベルに応じて初回ボーナスカード付与
        let userLevel = DataStore.shared.getUserLevel(userId: user.id)?.currentLevel ?? 1
        if userLevel >= 10 {
            grantWelcomeCards(to: user, level: userLevel)
        }
    }
    
    private static func grantWelcomeCards(to user: User, level: Int) {
        let welcomeCards = calculateWelcomeCards(level: level)
        let collection = DataStore.shared.getGachaCollection(userId: user.id)!
        
        for cardId in welcomeCards {
            let card = CollectionCard(
                cardDataId: cardId,
                obtainedDate: Date(),
                obtainedMethod: .special
            )
            collection.ownedCards.append(card)
        }
        
        DataStore.shared.saveGachaCollection(collection)
    }
    
    private static func calculateWelcomeCards(level: Int) -> [String] {
        var cards: [String] = []
        
        // レベル10以上：ノーマルカード3枚
        if level >= 10 {
            cards.append(contentsOf: ["char_1_warrior", "char_2_warrior", "char_3_warrior"])
        }
        
        // レベル25以上：レアカード1枚追加
        if level >= 25 {
            cards.append("char_5_knight")
        }
        
        // レベル40以上：スーパーレアカード1枚追加
        if level >= 40 {
            cards.append("char_7_master")
        }
        
        return cards
    }
    
    private static func initializeMonthlyStats(for user: User) {
        let currentDate = Date()
        let year = Calendar.current.component(.year, from: currentDate)
        let month = Calendar.current.component(.month, from: currentDate)
        
        // 現在月の統計データ作成
        let monthlyStats = MonthlyUserStats(
            userId: user.id,
            year: year,
            month: month
        )
        
        DataStore.shared.saveMonthlyStats(monthlyStats)
        
        // 各段の統計データも作成
        for table in 1...9 {
            let tableStats = TableMonthlyStats(
                userId: user.id,
                year: year,
                month: month,
                table: table
            )
            DataStore.shared.saveTableStats(tableStats)
        }
    }
    
    private static func initializeUsageStats(for user: User) {
        let currentDate = Date()
        let year = Calendar.current.component(.year, from: currentDate)
        let month = Calendar.current.component(.month, from: currentDate)
        
        let usageStats = NewFeatureUsageStats(
            userId: user.id,
            year: year,
            month: month
        )
        
        DataStore.shared.saveUsageStats(usageStats)
    }
}
```

### 2.2 データ整合性保証

```swift
// MARK: - データ整合性チェック

class DataIntegrityValidator {
    
    /// 新機能データの整合性チェック
    static func validateNewFeatureData() -> ValidationResult {
        var issues: [DataIssue] = []
        
        // 1. キャラクターデータの整合性
        issues.append(contentsOf: validateCharacterData())
        
        // 2. ガチャコレクションの整合性
        issues.append(contentsOf: validateGachaData())
        
        // 3. ランキングデータの整合性
        issues.append(contentsOf: validateRankingData())
        
        // 4. 統計データの整合性
        issues.append(contentsOf: validateStatsData())
        
        return ValidationResult(
            isValid: issues.isEmpty,
            issues: issues
        )
    }
    
    private static func validateCharacterData() -> [DataIssue] {
        var issues: [DataIssue] = []
        
        let characters = DataStore.shared.getAllCharacters()
        for character in characters {
            // レベルと進化段階の整合性
            let expectedStage = CharacterEvolutionManager.getEvolutionStage(
                for: character.characterType,
                level: character.currentLevel
            )
            
            if character.evolutionStage != expectedStage {
                issues.append(DataIssue(
                    type: .characterInconsistency,
                    description: "Character \(character.id) has inconsistent evolution stage"
                ))
            }
            
            // ルームデータの存在チェック
            if character.room == nil {
                issues.append(DataIssue(
                    type: .missingRoomData,
                    description: "Character \(character.id) has no room data"
                ))
            }
        }
        
        return issues
    }
    
    private static func validateGachaData() -> [DataIssue] {
        var issues: [DataIssue] = []
        
        let collections = DataStore.shared.getAllGachaCollections()
        for collection in collections {
            // ガチャ回数の整合性
            let totalFromTypes = collection.normalGachaCount + 
                                collection.premiumGachaCount + 
                                collection.tenPullGachaCount + 
                                collection.limitedGachaCount
            
            if totalFromTypes != collection.totalGachaCount {
                issues.append(DataIssue(
                    type: .gachaCountInconsistency,
                    description: "Collection \(collection.id) has inconsistent gacha counts"
                ))
            }
            
            // カードデータの存在チェック
            for card in collection.ownedCards {
                if !CardDatabase.cardExists(id: card.cardDataId) {
                    issues.append(DataIssue(
                        type: .invalidCardReference,
                        description: "Card \(card.cardDataId) does not exist in database"
                    ))
                }
            }
        }
        
        return issues
    }
    
    private static func validateRankingData() -> [DataIssue] {
        var issues: [DataIssue] = []
        
        let rankings = DataStore.shared.getAllRankings()
        for ranking in rankings {
            // 順位の重複チェック
            let ranks = ranking.entries.map { $0.rank }
            let uniqueRanks = Set(ranks)
            
            if ranks.count != uniqueRanks.count {
                issues.append(DataIssue(
                    type: .duplicateRanks,
                    description: "Ranking \(ranking.id) has duplicate ranks"
                ))
            }
            
            // 順位の連続性チェック
            let sortedRanks = ranks.sorted()
            for (index, rank) in sortedRanks.enumerated() {
                if rank != index + 1 {
                    issues.append(DataIssue(
                        type: .nonConsecutiveRanks,
                        description: "Ranking \(ranking.id) has non-consecutive ranks"
                    ))
                    break
                }
            }
        }
        
        return issues
    }
    
    private static func validateStatsData() -> [DataIssue] {
        var issues: [DataIssue] = []
        
        let allUsers = DataStore.shared.getAllUsers()
        for user in allUsers {
            let currentMonth = getCurrentYearMonth()
            
            // 月次統計の存在チェック
            if DataStore.shared.getMonthlyStats(userId: user.id, month: currentMonth) == nil {
                issues.append(DataIssue(
                    type: .missingMonthlyStats,
                    description: "User \(user.id) missing monthly stats for \(currentMonth)"
                ))
            }
            
            // 各段統計の存在チェック
            for table in 1...9 {
                if DataStore.shared.getTableStats(userId: user.id, table: table, month: currentMonth) == nil {
                    issues.append(DataIssue(
                        type: .missingTableStats,
                        description: "User \(user.id) missing table \(table) stats for \(currentMonth)"
                    ))
                }
            }
        }
        
        return issues
    }
    
    /// データ修復実行
    static func repairDataIssues(_ issues: [DataIssue]) {
        for issue in issues {
            switch issue.type {
            case .characterInconsistency:
                repairCharacterInconsistency(issue)
            case .missingRoomData:
                repairMissingRoomData(issue)
            case .gachaCountInconsistency:
                repairGachaCountInconsistency(issue)
            case .invalidCardReference:
                repairInvalidCardReference(issue)
            case .duplicateRanks:
                repairDuplicateRanks(issue)
            case .nonConsecutiveRanks:
                repairNonConsecutiveRanks(issue)
            case .missingMonthlyStats:
                repairMissingMonthlyStats(issue)
            case .missingTableStats:
                repairMissingTableStats(issue)
            }
        }
    }
    
    // 修復処理の実装...
    private static func repairCharacterInconsistency(_ issue: DataIssue) {
        // キャラクター整合性修復
    }
    
    private static func repairMissingRoomData(_ issue: DataIssue) {
        // ルームデータ作成
    }
    
    // ... 他の修復メソッド
    
    private static func getCurrentYearMonth() -> YearMonth {
        let now = Date()
        return YearMonth(
            year: Calendar.current.component(.year, from: now),
            month: Calendar.current.component(.month, from: now)
        )
    }
}

struct ValidationResult {
    let isValid: Bool
    let issues: [DataIssue]
}

struct DataIssue {
    let type: DataIssueType
    let description: String
}

enum DataIssueType {
    case characterInconsistency
    case missingRoomData
    case gachaCountInconsistency
    case invalidCardReference
    case duplicateRanks
    case nonConsecutiveRanks
    case missingMonthlyStats
    case missingTableStats
}
```

この詳細仕様書により、新機能に必要な全てのデータモデルが SwiftData で正しく定義され、既存データとの整合性も保たれます。