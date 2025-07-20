# 月次ランキングシステム 詳細仕様書

## 1. ランキングシステム基礎仕様

### 1.1 ランキング種別定義

```swift
enum RankingType: String, CaseIterable {
    // 総合ランキング
    case monthlyPoints = "monthly_points"           // 月間獲得ポイント
    case monthlyProblems = "monthly_problems"       // 月間問題数
    case monthlyAccuracy = "monthly_accuracy"       // 月間正解率
    
    // 段別ランキング
    case table1Master = "table_1_master"           // 1の段マスター
    case table2Master = "table_2_master"           // 2の段マスター
    case table3Master = "table_3_master"           // 3の段マスター
    case table4Master = "table_4_master"           // 4の段マスター
    case table5Master = "table_5_master"           // 5の段マスター
    case table6Master = "table_6_master"           // 6の段マスター
    case table7Master = "table_7_master"           // 7の段マスター
    case table8Master = "table_8_master"           // 8の段マスター
    case table9Master = "table_9_master"           // 9の段マスター
    
    // 学年別ランキング
    case grade1 = "grade_1"                        // 小学1年生
    case grade2 = "grade_2"                        // 小学2年生
    case grade3 = "grade_3"                        // 小学3年生
    case grade4Plus = "grade_4_plus"               // 小学4年生以上
    
    // 特別ランキング
    case challengeStreak = "challenge_streak"       // チャレンジ連続達成
    case loginStreak = "login_streak"              // 連続ログイン
    case difficultConquer = "difficult_conquer"     // 苦手問題克服
    case speedMaster = "speed_master"              // 最速回答
    
    // 地域別ランキング（オプション）
    case prefectureRanking = "prefecture"          // 都道府県別
    case cityRanking = "city"                      // 市区町村別
    
    var displayName: String {
        switch self {
        case .monthlyPoints: return NSLocalizedString("monthly_points_ranking", comment: "月間ポイントランキング")
        case .monthlyProblems: return NSLocalizedString("monthly_problems_ranking", comment: "月間問題数ランキング")
        case .monthlyAccuracy: return NSLocalizedString("monthly_accuracy_ranking", comment: "月間正解率ランキング")
        case .table1Master: return NSLocalizedString("table_1_ranking", comment: "1の段ランキング")
        case .table2Master: return NSLocalizedString("table_2_ranking", comment: "2の段ランキング")
        case .table3Master: return NSLocalizedString("table_3_ranking", comment: "3の段ランキング")
        case .table4Master: return NSLocalizedString("table_4_ranking", comment: "4の段ランキング")
        case .table5Master: return NSLocalizedString("table_5_ranking", comment: "5の段ランキング")
        case .table6Master: return NSLocalizedString("table_6_ranking", comment: "6の段ランキング")
        case .table7Master: return NSLocalizedString("table_7_ranking", comment: "7の段ランキング")
        case .table8Master: return NSLocalizedString("table_8_ranking", comment: "8の段ランキング")
        case .table9Master: return NSLocalizedString("table_9_ranking", comment: "9の段ランキング")
        case .grade1: return NSLocalizedString("grade_1_ranking", comment: "小学1年生ランキング")
        case .grade2: return NSLocalizedString("grade_2_ranking", comment: "小学2年生ランキング")
        case .grade3: return NSLocalizedString("grade_3_ranking", comment: "小学3年生ランキング")
        case .grade4Plus: return NSLocalizedString("grade_4_plus_ranking", comment: "小学4年生以上ランキング")
        case .challengeStreak: return NSLocalizedString("challenge_streak_ranking", comment: "チャレンジ連続達成ランキング")
        case .loginStreak: return NSLocalizedString("login_streak_ranking", comment: "連続ログインランキング")
        case .difficultConquer: return NSLocalizedString("difficult_conquer_ranking", comment: "苦手克服ランキング")
        case .speedMaster: return NSLocalizedString("speed_master_ranking", comment: "スピードマスターランキング")
        case .prefectureRanking: return NSLocalizedString("prefecture_ranking", comment: "都道府県ランキング")
        case .cityRanking: return NSLocalizedString("city_ranking", comment: "市区町村ランキング")
        }
    }
    
    var category: RankingCategory {
        switch self {
        case .monthlyPoints, .monthlyProblems, .monthlyAccuracy:
            return .general
        case .table1Master, .table2Master, .table3Master, .table4Master, .table5Master,
             .table6Master, .table7Master, .table8Master, .table9Master:
            return .tableSpecific
        case .grade1, .grade2, .grade3, .grade4Plus:
            return .gradeSpecific
        case .challengeStreak, .loginStreak, .difficultConquer, .speedMaster:
            return .special
        case .prefectureRanking, .cityRanking:
            return .regional
        }
    }
    
    var minimumQualification: RankingQualification {
        switch self {
        case .monthlyPoints, .monthlyProblems:
            return .minProblems(50)
        case .monthlyAccuracy:
            return .minProblems(100)  // 正解率は100問以上で有効
        case .table1Master, .table2Master, .table3Master, .table4Master, .table5Master,
             .table6Master, .table7Master, .table8Master, .table9Master:
            return .tableProblems(extractTableNumber(), min: 20)
        case .grade1, .grade2, .grade3, .grade4Plus:
            return .gradeAndProblems(extractGrade(), min: 30)
        case .challengeStreak:
            return .challengeParticipation(7)  // 7日以上のチャレンジ参加
        case .loginStreak:
            return .loginDays(7)  // 7日以上のログイン
        case .difficultConquer:
            return .difficultProblems(10)  // 苦手問題10問以上
        case .speedMaster:
            return .fastAnswers(50)  // 3秒以内回答50回以上
        case .prefectureRanking, .cityRanking:
            return .locationSet
        }
    }
    
    private func extractTableNumber() -> Int {
        switch self {
        case .table1Master: return 1
        case .table2Master: return 2
        case .table3Master: return 3
        case .table4Master: return 4
        case .table5Master: return 5
        case .table6Master: return 6
        case .table7Master: return 7
        case .table8Master: return 8
        case .table9Master: return 9
        default: return 1
        }
    }
    
    private func extractGrade() -> Int {
        switch self {
        case .grade1: return 1
        case .grade2: return 2
        case .grade3: return 3
        case .grade4Plus: return 4
        default: return 2
        }
    }
}

enum RankingCategory: String, CaseIterable {
    case general = "general"           // 総合
    case tableSpecific = "table"       // 段別
    case gradeSpecific = "grade"       // 学年別
    case special = "special"           // 特別
    case regional = "regional"         // 地域別
    
    var displayName: String {
        switch self {
        case .general: return NSLocalizedString("general_ranking", comment: "総合ランキング")
        case .tableSpecific: return NSLocalizedString("table_ranking", comment: "段別ランキング")
        case .gradeSpecific: return NSLocalizedString("grade_ranking", comment: "学年別ランキング")
        case .special: return NSLocalizedString("special_ranking", comment: "特別ランキング")
        case .regional: return NSLocalizedString("regional_ranking", comment: "地域別ランキング")
        }
    }
}

enum RankingQualification {
    case minProblems(Int)
    case tableProblems(Int, min: Int)
    case gradeAndProblems(Int, min: Int)
    case challengeParticipation(Int)
    case loginDays(Int)
    case difficultProblems(Int)
    case fastAnswers(Int)
    case locationSet
}
```

### 1.2 ランキング集計システム

```swift
class RankingAggregationSystem {
    
    /// 月次ランキング更新
    static func updateMonthlyRankings(for month: YearMonth) {
        for rankingType in RankingType.allCases {
            updateRanking(type: rankingType, month: month)
        }
    }
    
    /// 個別ランキング更新
    static func updateRanking(type: RankingType, month: YearMonth) {
        let participants = getQualifiedParticipants(type: type, month: month)
        let rankedEntries = calculateRanking(type: type, participants: participants, month: month)
        saveRanking(type: type, month: month, entries: rankedEntries)
    }
    
    /// 参加資格者取得
    private static func getQualifiedParticipants(
        type: RankingType,
        month: YearMonth
    ) -> [RankingParticipant] {
        
        let allUsers = DataStore.shared.getAllUsers()
        var qualifiedUsers: [RankingParticipant] = []
        
        for user in allUsers {
            if isQualified(user: user, for: type, month: month) {
                let participant = createParticipant(user: user, type: type, month: month)
                qualifiedUsers.append(participant)
            }
        }
        
        return qualifiedUsers
    }
    
    /// 参加資格チェック
    private static func isQualified(
        user: User,
        for type: RankingType,
        month: YearMonth
    ) -> Bool {
        
        let qualification = type.minimumQualification
        let monthlyStats = getMonthlyStats(user: user, month: month)
        
        switch qualification {
        case .minProblems(let min):
            return monthlyStats.totalProblems >= min
            
        case .tableProblems(let table, let min):
            let tableStats = getTableStats(user: user, table: table, month: month)
            return tableStats.totalProblems >= min
            
        case .gradeAndProblems(let grade, let min):
            return user.grade == grade && monthlyStats.totalProblems >= min
            
        case .challengeParticipation(let days):
            return monthlyStats.challengeParticipationDays >= days
            
        case .loginDays(let days):
            return monthlyStats.loginDays >= days
            
        case .difficultProblems(let min):
            return monthlyStats.difficultProblemsAttempted >= min
            
        case .fastAnswers(let min):
            return monthlyStats.fastAnswersCount >= min
            
        case .locationSet:
            return user.prefecture != nil && user.city != nil
        }
    }
    
    /// 参加者データ作成
    private static func createParticipant(
        user: User,
        type: RankingType,
        month: YearMonth
    ) -> RankingParticipant {
        
        let score = calculateScore(user: user, type: type, month: month)
        let previousScore = calculateScore(user: user, type: type, month: month.previous())
        
        return RankingParticipant(
            userId: user.id,
            userName: user.displayName,
            grade: user.grade,
            prefecture: user.prefecture,
            city: user.city,
            avatar: user.avatar,
            score: score,
            previousScore: previousScore,
            lastActive: user.lastActiveDate
        )
    }
    
    /// スコア計算
    private static func calculateScore(
        user: User,
        type: RankingType,
        month: YearMonth
    ) -> Int {
        
        let monthlyStats = getMonthlyStats(user: user, month: month)
        
        switch type {
        case .monthlyPoints:
            return monthlyStats.totalPointsEarned
            
        case .monthlyProblems:
            return monthlyStats.totalProblems
            
        case .monthlyAccuracy:
            if monthlyStats.totalProblems >= 100 {
                return Int(monthlyStats.accuracy * 10000) // 精度のため10000倍
            }
            return 0
            
        case .table1Master, .table2Master, .table3Master, .table4Master, .table5Master,
             .table6Master, .table7Master, .table8Master, .table9Master:
            let table = type.extractTableNumber()
            let tableStats = getTableStats(user: user, table: table, month: month)
            return tableStats.correctAnswers
            
        case .grade1, .grade2, .grade3, .grade4Plus:
            return monthlyStats.totalPointsEarned // 学年別は総合ポイントで競争
            
        case .challengeStreak:
            return monthlyStats.maxChallengeStreak
            
        case .loginStreak:
            return monthlyStats.maxLoginStreak
            
        case .difficultConquer:
            return monthlyStats.difficultProblemsConquered
            
        case .speedMaster:
            return monthlyStats.fastAnswersCount
            
        case .prefectureRanking, .cityRanking:
            return monthlyStats.totalPointsEarned
        }
    }
    
    /// ランキング計算
    private static func calculateRanking(
        type: RankingType,
        participants: [RankingParticipant],
        month: YearMonth
    ) -> [RankingEntry] {
        
        // スコア順にソート
        let sortedParticipants = participants.sorted { $0.score > $1.score }
        
        var entries: [RankingEntry] = []
        var currentRank = 1
        
        for (index, participant) in sortedParticipants.enumerated() {
            // 同スコアの場合は同順位
            if index > 0 && participant.score < sortedParticipants[index - 1].score {
                currentRank = index + 1
            }
            
            let previousRank = getPreviousRank(
                participant: participant,
                type: type,
                month: month.previous()
            )
            
            let entry = RankingEntry(
                userId: participant.userId,
                userName: participant.userName,
                grade: participant.grade,
                prefecture: participant.prefecture,
                city: participant.city,
                avatar: participant.avatar,
                rank: currentRank,
                score: participant.score,
                previousRank: previousRank,
                rankChange: calculateRankChange(currentRank: currentRank, previousRank: previousRank),
                badges: getUserBadges(userId: participant.userId),
                lastActive: participant.lastActive
            )
            
            entries.append(entry)
        }
        
        return entries
    }
    
    /// 前回順位取得
    private static func getPreviousRank(
        participant: RankingParticipant,
        type: RankingType,
        month: YearMonth
    ) -> Int? {
        let previousRanking = DataStore.shared.getRanking(type: type, month: month)
        return previousRanking?.entries.first { $0.userId == participant.userId }?.rank
    }
    
    /// 順位変動計算
    private static func calculateRankChange(
        currentRank: Int,
        previousRank: Int?
    ) -> RankChange {
        guard let previousRank = previousRank else {
            return .new
        }
        
        if currentRank < previousRank {
            return .up(previousRank - currentRank)
        } else if currentRank > previousRank {
            return .down(currentRank - previousRank)
        } else {
            return .same
        }
    }
    
    /// ユーザーバッジ取得
    private static func getUserBadges(userId: UUID) -> [Badge] {
        return DataStore.shared.getUserBadges(userId: userId)
    }
    
    /// ランキング保存
    private static func saveRanking(
        type: RankingType,
        month: YearMonth,
        entries: [RankingEntry]
    ) {
        let ranking = MonthlyRanking(
            id: UUID(),
            year: month.year,
            month: month.month,
            rankingType: type,
            entries: entries,
            lastUpdated: Date(),
            totalParticipants: entries.count
        )
        
        DataStore.shared.saveRanking(ranking)
    }
    
    // MARK: - Helper Methods
    
    private static func getMonthlyStats(user: User, month: YearMonth) -> MonthlyUserStats {
        return DataStore.shared.getMonthlyStats(userId: user.id, month: month)
    }
    
    private static func getTableStats(user: User, table: Int, month: YearMonth) -> TableMonthlyStats {
        return DataStore.shared.getTableStats(userId: user.id, table: table, month: month)
    }
}

struct YearMonth: Hashable {
    let year: Int
    let month: Int
    
    func previous() -> YearMonth {
        if month == 1 {
            return YearMonth(year: year - 1, month: 12)
        } else {
            return YearMonth(year: year, month: month - 1)
        }
    }
    
    func next() -> YearMonth {
        if month == 12 {
            return YearMonth(year: year + 1, month: 1)
        } else {
            return YearMonth(year: year, month: month + 1)
        }
    }
}

struct RankingParticipant {
    let userId: UUID
    let userName: String
    let grade: Int?
    let prefecture: String?
    let city: String?
    let avatar: UserAvatar
    let score: Int
    let previousScore: Int
    let lastActive: Date
}

struct MonthlyUserStats {
    let totalProblems: Int
    let totalPointsEarned: Int
    let accuracy: Double
    let challengeParticipationDays: Int
    let loginDays: Int
    let difficultProblemsAttempted: Int
    let difficultProblemsConquered: Int
    let fastAnswersCount: Int
    let maxChallengeStreak: Int
    let maxLoginStreak: Int
}

struct TableMonthlyStats {
    let table: Int
    let totalProblems: Int
    let correctAnswers: Int
    let accuracy: Double
    let averageTime: Double
}

enum RankChange {
    case new
    case up(Int)
    case down(Int)
    case same
    
    var description: String {
        switch self {
        case .new: return NSLocalizedString("rank_new", comment: "初参加")
        case .up(let positions): return NSLocalizedString("rank_up", comment: "↑\(positions)")
        case .down(let positions): return NSLocalizedString("rank_down", comment: "↓\(positions)")
        case .same: return NSLocalizedString("rank_same", comment: "→")
        }
    }
    
    var color: Color {
        switch self {
        case .new: return .blue
        case .up: return .green
        case .down: return .red
        case .same: return .gray
        }
    }
}
```

## 2. 報酬システム

### 2.1 ランキング報酬定義

```swift
class RankingRewardSystem {
    
    /// 月次報酬配布
    static func distributeMonthlyRewards(month: YearMonth) {
        
        for rankingType in RankingType.allCases {
            guard let ranking = DataStore.shared.getRanking(type: rankingType, month: month) else {
                continue
            }
            
            let rewards = calculateRewards(ranking: ranking)
            distributeRewards(rewards: rewards, month: month)
        }
        
        // 参加報酬も配布
        distributeParticipationRewards(month: month)
    }
    
    /// 報酬計算
    private static func calculateRewards(ranking: MonthlyRanking) -> [UserReward] {
        var rewards: [UserReward] = []
        
        for entry in ranking.entries {
            let reward = calculateIndividualReward(
                entry: entry,
                rankingType: ranking.rankingType,
                totalParticipants: ranking.totalParticipants
            )
            
            if reward.totalValue > 0 {
                rewards.append(UserReward(
                    userId: entry.userId,
                    reward: reward,
                    rankingType: ranking.rankingType,
                    rank: entry.rank,
                    month: YearMonth(year: ranking.year, month: ranking.month)
                ))
            }
        }
        
        return rewards
    }
    
    /// 個人報酬計算
    private static func calculateIndividualReward(
        entry: RankingEntry,
        rankingType: RankingType,
        totalParticipants: Int
    ) -> Reward {
        
        let rank = entry.rank
        let category = rankingType.category
        
        // 基本報酬テーブル
        var points = 0
        var specialCards: [CollectionCard] = []
        var badges: [Badge] = []
        var title: String? = nil
        
        // カテゴリ別基本報酬
        let baseReward = getBaseReward(category: category)
        
        switch rank {
        case 1:
            // 1位報酬
            points = baseReward.firstPlace.points
            if let cardId = baseReward.firstPlace.specialCardId {
                specialCards.append(createSpecialCard(cardId: cardId, rank: rank))
            }
            title = generateRankingTitle(rankingType: rankingType, rank: rank)
            badges.append(createRankingBadge(rankingType: rankingType, rank: rank))
            
        case 2...3:
            // 2-3位報酬
            points = baseReward.secondThirdPlace.points
            if let cardId = baseReward.secondThirdPlace.specialCardId {
                specialCards.append(createSpecialCard(cardId: cardId, rank: rank))
            }
            badges.append(createRankingBadge(rankingType: rankingType, rank: rank))
            
        case 4...10:
            // 4-10位報酬
            points = baseReward.topTen.points
            if let cardId = baseReward.topTen.specialCardId {
                specialCards.append(createSpecialCard(cardId: cardId, rank: rank))
            }
            
        case 11...50:
            // 11-50位報酬
            points = baseReward.topFifty.points
            
        case 51...100:
            // 51-100位報酬
            points = baseReward.topHundred.points
            
        default:
            // 参加賞
            points = baseReward.participation.points
        }
        
        // 特別ボーナス
        if let bonusPoints = calculateSpecialBonus(entry: entry, rankingType: rankingType) {
            points += bonusPoints
        }
        
        return Reward(
            points: points,
            specialCards: specialCards,
            badges: badges,
            title: title,
            gachaTickets: calculateGachaTickets(rank: rank, category: category)
        )
    }
    
    /// 基本報酬テーブル取得
    private static func getBaseReward(category: RankingCategory) -> BaseRewardTable {
        switch category {
        case .general:
            return BaseRewardTable(
                firstPlace: RewardTier(points: 100, specialCardId: "legend_first_place"),
                secondThirdPlace: RewardTier(points: 50, specialCardId: "rare_high_rank"),
                topTen: RewardTier(points: 30, specialCardId: nil),
                topFifty: RewardTier(points: 20, specialCardId: nil),
                topHundred: RewardTier(points: 10, specialCardId: nil),
                participation: RewardTier(points: 5, specialCardId: nil)
            )
            
        case .tableSpecific:
            return BaseRewardTable(
                firstPlace: RewardTier(points: 50, specialCardId: "table_master_card"),
                secondThirdPlace: RewardTier(points: 30, specialCardId: nil),
                topTen: RewardTier(points: 20, specialCardId: nil),
                topFifty: RewardTier(points: 15, specialCardId: nil),
                topHundred: RewardTier(points: 10, specialCardId: nil),
                participation: RewardTier(points: 3, specialCardId: nil)
            )
            
        case .gradeSpecific:
            return BaseRewardTable(
                firstPlace: RewardTier(points: 80, specialCardId: "grade_champion_card"),
                secondThirdPlace: RewardTier(points: 40, specialCardId: nil),
                topTen: RewardTier(points: 25, specialCardId: nil),
                topFifty: RewardTier(points: 15, specialCardId: nil),
                topHundred: RewardTier(points: 8, specialCardId: nil),
                participation: RewardTier(points: 3, specialCardId: nil)
            )
            
        case .special:
            return BaseRewardTable(
                firstPlace: RewardTier(points: 60, specialCardId: "special_achievement_card"),
                secondThirdPlace: RewardTier(points: 35, specialCardId: nil),
                topTen: RewardTier(points: 20, specialCardId: nil),
                topFifty: RewardTier(points: 12, specialCardId: nil),
                topHundred: RewardTier(points: 6, specialCardId: nil),
                participation: RewardTier(points: 2, specialCardId: nil)
            )
            
        case .regional:
            return BaseRewardTable(
                firstPlace: RewardTier(points: 70, specialCardId: "regional_hero_card"),
                secondThirdPlace: RewardTier(points: 35, specialCardId: nil),
                topTen: RewardTier(points: 20, specialCardId: nil),
                topFifty: RewardTier(points: 12, specialCardId: nil),
                topHundred: RewardTier(points: 6, specialCardId: nil),
                participation: RewardTier(points: 3, specialCardId: nil)
            )
        }
    }
    
    /// 特別ボーナス計算
    private static func calculateSpecialBonus(
        entry: RankingEntry,
        rankingType: RankingType
    ) -> Int? {
        
        var bonus = 0
        
        // 連続ランクイン ボーナス
        if let previousRank = entry.previousRank, previousRank <= 10 && entry.rank <= 10 {
            bonus += 10 // 連続TOP10ボーナス
        }
        
        // 大幅ランクアップ ボーナス
        if case .up(let positions) = entry.rankChange, positions >= 50 {
            bonus += positions / 10 // 大幅上昇ボーナス
        }
        
        // 新人ボーナス
        if case .new = entry.rankChange {
            bonus += 5
        }
        
        return bonus > 0 ? bonus : nil
    }
    
    /// ガチャチケット計算
    private static func calculateGachaTickets(rank: Int, category: RankingCategory) -> Int {
        let baseTickets: Int
        
        switch category {
        case .general:
            baseTickets = 3
        case .tableSpecific:
            baseTickets = 2
        case .gradeSpecific:
            baseTickets = 2
        case .special:
            baseTickets = 1
        case .regional:
            baseTickets = 1
        }
        
        switch rank {
        case 1:
            return baseTickets * 3
        case 2...3:
            return baseTickets * 2
        case 4...10:
            return baseTickets
        case 11...50:
            return max(1, baseTickets / 2)
        default:
            return 0
        }
    }
    
    /// 参加報酬配布
    private static func distributeParticipationRewards(month: YearMonth) {
        let allUsers = DataStore.shared.getAllUsers()
        
        for user in allUsers {
            let monthlyStats = DataStore.shared.getMonthlyStats(userId: user.id, month: month)
            let participationReward = calculateParticipationReward(stats: monthlyStats)
            
            if participationReward.totalValue > 0 {
                let userReward = UserReward(
                    userId: user.id,
                    reward: participationReward,
                    rankingType: .monthlyProblems, // 代表として
                    rank: nil,
                    month: month
                )
                DataStore.shared.saveUserReward(userReward)
            }
        }
    }
    
    /// 参加報酬計算
    private static func calculateParticipationReward(stats: MonthlyUserStats) -> Reward {
        var points = 0
        var badges: [Badge] = []
        
        // 月間100問以上
        if stats.totalProblems >= 100 {
            points += 5
            badges.append(createParticipationBadge(type: .month100Problems))
        }
        
        // 月間500問以上
        if stats.totalProblems >= 500 {
            points += 10
            badges.append(createParticipationBadge(type: .month500Problems))
        }
        
        // 月間1000問以上
        if stats.totalProblems >= 1000 {
            points += 20
            badges.append(createParticipationBadge(type: .month1000Problems))
        }
        
        return Reward(
            points: points,
            specialCards: [],
            badges: badges,
            title: nil,
            gachaTickets: 0
        )
    }
    
    // MARK: - Helper Methods
    
    private static func createSpecialCard(cardId: String, rank: Int) -> CollectionCard {
        // 実装: 特別カード作成
        let cardData = CardDatabase.allCards.first { $0.id == cardId }!
        return CollectionCard(
            id: UUID(),
            cardData: cardData,
            obtainedDate: Date(),
            obtainedCount: 1,
            obtainedMethod: .rankingReward(rank: rank)
        )
    }
    
    private static func createRankingBadge(rankingType: RankingType, rank: Int) -> Badge {
        return Badge(
            id: UUID(),
            type: .rankingAchievement(rankingType, rank),
            name: generateBadgeName(rankingType: rankingType, rank: rank),
            description: generateBadgeDescription(rankingType: rankingType, rank: rank),
            imageAssetName: generateBadgeAsset(rankingType: rankingType, rank: rank),
            earnedDate: Date(),
            rarity: determineBadgeRarity(rank: rank)
        )
    }
    
    private static func generateRankingTitle(rankingType: RankingType, rank: Int) -> String {
        switch (rankingType.category, rank) {
        case (.general, 1):
            return NSLocalizedString("monthly_champion", comment: "月間チャンピオン")
        case (.tableSpecific, 1):
            let table = rankingType.extractTableNumber()
            return NSLocalizedString("table_king", comment: "\(table)の段の王")
        case (.gradeSpecific, 1):
            let grade = rankingType.extractGrade()
            return NSLocalizedString("grade_master", comment: "\(grade)年生マスター")
        default:
            return NSLocalizedString("ranking_achiever", comment: "ランキング入賞者")
        }
    }
    
    private static func generateBadgeName(rankingType: RankingType, rank: Int) -> String {
        switch rank {
        case 1: return NSLocalizedString("first_place_badge", comment: "1位のバッジ")
        case 2: return NSLocalizedString("second_place_badge", comment: "2位のバッジ")
        case 3: return NSLocalizedString("third_place_badge", comment: "3位のバッジ")
        default: return NSLocalizedString("ranking_badge", comment: "ランキングバッジ")
        }
    }
    
    private static func generateBadgeDescription(rankingType: RankingType, rank: Int) -> String {
        return NSLocalizedString("ranking_badge_desc", comment: "\(rankingType.displayName)で\(rank)位を獲得")
    }
    
    private static func generateBadgeAsset(rankingType: RankingType, rank: Int) -> String {
        return "badge_ranking_\(rankingType.rawValue)_rank\(rank)"
    }
    
    private static func determineBadgeRarity(rank: Int) -> BadgeRarity {
        switch rank {
        case 1: return .legendary
        case 2...3: return .epic
        case 4...10: return .rare
        default: return .common
        }
    }
    
    private static func createParticipationBadge(type: ParticipationBadgeType) -> Badge {
        return Badge(
            id: UUID(),
            type: .participation(type),
            name: type.displayName,
            description: type.description,
            imageAssetName: type.assetName,
            earnedDate: Date(),
            rarity: .common
        )
    }
    
    /// 報酬配布
    private static func distributeRewards(rewards: [UserReward], month: YearMonth) {
        for reward in rewards {
            DataStore.shared.saveUserReward(reward)
            
            // プッシュ通知送信
            sendRewardNotification(reward: reward)
        }
    }
    
    private static func sendRewardNotification(reward: UserReward) {
        let message: String
        if let rank = reward.rank {
            message = NSLocalizedString("ranking_reward_notification", 
                comment: "\(reward.rankingType.displayName)で\(rank)位！報酬を受け取りました")
        } else {
            message = NSLocalizedString("participation_reward_notification", 
                comment: "月間参加報酬を受け取りました！")
        }
        
        NotificationService.sendLocalNotification(
            to: reward.userId,
            title: NSLocalizedString("ranking_reward_title", comment: "ランキング報酬"),
            body: message
        )
    }
}

struct BaseRewardTable {
    let firstPlace: RewardTier
    let secondThirdPlace: RewardTier
    let topTen: RewardTier
    let topFifty: RewardTier
    let topHundred: RewardTier
    let participation: RewardTier
}

struct RewardTier {
    let points: Int
    let specialCardId: String?
}

struct Reward {
    let points: Int
    let specialCards: [CollectionCard]
    let badges: [Badge]
    let title: String?
    let gachaTickets: Int
    
    var totalValue: Int {
        return points + (gachaTickets * 10) + (specialCards.count * 50)
    }
}

struct UserReward {
    let userId: UUID
    let reward: Reward
    let rankingType: RankingType
    let rank: Int?
    let month: YearMonth
}

enum ParticipationBadgeType {
    case month100Problems
    case month500Problems
    case month1000Problems
    
    var displayName: String {
        switch self {
        case .month100Problems: return NSLocalizedString("month_100_badge", comment: "月間100問バッジ")
        case .month500Problems: return NSLocalizedString("month_500_badge", comment: "月間500問バッジ")
        case .month1000Problems: return NSLocalizedString("month_1000_badge", comment: "月間1000問バッジ")
        }
    }
    
    var description: String {
        switch self {
        case .month100Problems: return NSLocalizedString("month_100_desc", comment: "月間100問以上解答")
        case .month500Problems: return NSLocalizedString("month_500_desc", comment: "月間500問以上解答")
        case .month1000Problems: return NSLocalizedString("month_1000_desc", comment: "月間1000問以上解答")
        }
    }
    
    var assetName: String {
        switch self {
        case .month100Problems: return "badge_month_100"
        case .month500Problems: return "badge_month_500"
        case .month1000Problems: return "badge_month_1000"
        }
    }
}
```

## 3. プライバシー保護システム

### 3.1 プライバシー設定

```swift
class RankingPrivacyManager {
    
    enum PrivacyLevel: Int, CaseIterable {
        case full = 0           // 全情報表示
        case limitedInfo = 1    // 一部情報制限
        case avatarOnly = 2     // アバターのみ
        case anonymous = 3      // 完全匿名
        
        var displayName: String {
            switch self {
            case .full: return NSLocalizedString("privacy_full", comment: "すべて表示")
            case .limitedInfo: return NSLocalizedString("privacy_limited", comment: "一部制限")
            case .avatarOnly: return NSLocalizedString("privacy_avatar", comment: "アバターのみ")
            case .anonymous: return NSLocalizedString("privacy_anonymous", comment: "匿名")
            }
        }
    }
    
    /// プライバシー設定適用
    static func applyPrivacySettings(
        entry: RankingEntry,
        viewerPrivacy: PrivacyLevel,
        entryPrivacy: PrivacyLevel
    ) -> PublicRankingEntry {
        
        let effectivePrivacy = PrivacyLevel(rawValue: max(viewerPrivacy.rawValue, entryPrivacy.rawValue))!
        
        switch effectivePrivacy {
        case .full:
            return PublicRankingEntry(
                displayName: entry.userName,
                grade: entry.grade,
                prefecture: entry.prefecture,
                city: entry.city,
                avatar: entry.avatar,
                rank: entry.rank,
                score: entry.score,
                rankChange: entry.rankChange,
                badges: entry.badges.prefix(3).map { $0 } // 最大3個まで
            )
            
        case .limitedInfo:
            return PublicRankingEntry(
                displayName: entry.userName,
                grade: entry.grade,
                prefecture: entry.prefecture,
                city: nil, // 市区町村は非表示
                avatar: entry.avatar,
                rank: entry.rank,
                score: entry.score,
                rankChange: entry.rankChange,
                badges: []
            )
            
        case .avatarOnly:
            return PublicRankingEntry(
                displayName: generateAnonymousName(rank: entry.rank),
                grade: nil,
                prefecture: nil,
                city: nil,
                avatar: entry.avatar,
                rank: entry.rank,
                score: entry.score,
                rankChange: .same, // 変動情報も非表示
                badges: []
            )
            
        case .anonymous:
            return PublicRankingEntry(
                displayName: generateAnonymousName(rank: entry.rank),
                grade: nil,
                prefecture: nil,
                city: nil,
                avatar: generateAnonymousAvatar(),
                rank: entry.rank,
                score: entry.score,
                rankChange: .same,
                badges: []
            )
        }
    }
    
    /// 匿名名前生成
    private static func generateAnonymousName(rank: Int) -> String {
        let anonymousNames = [
            NSLocalizedString("anonymous_1", comment: "匿名ユーザー"),
            NSLocalizedString("anonymous_2", comment: "がんばりや"),
            NSLocalizedString("anonymous_3", comment: "九九マスター"),
            NSLocalizedString("anonymous_4", comment: "計算の達人"),
            NSLocalizedString("anonymous_5", comment: "数字の友達")
        ]
        
        let index = (rank - 1) % anonymousNames.count
        return anonymousNames[index]
    }
    
    /// 匿名アバター生成
    private static func generateAnonymousAvatar() -> UserAvatar {
        let colors: [Color] = [.gray, .blue, .green, .purple, .orange]
        let randomColor = colors.randomElement()!
        
        return UserAvatar(
            character: .robot, // 匿名は常にロボット
            backgroundColor: randomColor,
            accessories: []
        )
    }
    
    /// 年齢制限チェック
    static func checkAgeRestrictions(user: User) -> RankingAccessLevel {
        guard let birthDate = user.birthDate else {
            return .restricted // 年齢不明は制限
        }
        
        let age = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year!
        
        switch age {
        case 0...12:
            return .childRestricted // 12歳以下は制限
        case 13...17:
            return .teenRestricted  // 13-17歳は一部制限
        default:
            return .full            // 18歳以上は制限なし
        }
    }
    
    /// 地域情報の安全性チェック
    static func validateLocationSafety(prefecture: String?, city: String?) -> Bool {
        // 過度に詳細な位置情報は危険
        if let city = city {
            // 市区町村が設定されている場合の安全性チェック
            let dangerousKeywords = ["小学校", "中学校", "住所", "番地"]
            for keyword in dangerousKeywords {
                if city.contains(keyword) {
                    return false
                }
            }
        }
        
        return true
    }
}

enum RankingAccessLevel {
    case full
    case teenRestricted
    case childRestricted
    case restricted
    
    var allowedRankings: [RankingType] {
        switch self {
        case .full:
            return RankingType.allCases
        case .teenRestricted:
            return RankingType.allCases.filter { !$0.category == .regional }
        case .childRestricted:
            return [.monthlyPoints, .monthlyProblems, .grade1, .grade2, .grade3]
        case .restricted:
            return []
        }
    }
}

struct PublicRankingEntry {
    let displayName: String
    let grade: Int?
    let prefecture: String?
    let city: String?
    let avatar: UserAvatar
    let rank: Int
    let score: Int
    let rankChange: RankChange
    let badges: [Badge]
}
```

## 4. 月次リセット・メンテナンスシステム

### 4.1 自動メンテナンス

```swift
class RankingMaintenanceSystem {
    
    /// 月次メンテナンス実行
    static func executeMonthlyMaintenance() {
        let currentMonth = getCurrentYearMonth()
        let previousMonth = currentMonth.previous()
        
        // 1. 前月ランキング確定・報酬配布
        finalizeRankings(month: previousMonth)
        
        // 2. 新月ランキング初期化
        initializeNewMonth(month: currentMonth)
        
        // 3. 古いデータのクリーンアップ
        cleanupOldData()
        
        // 4. 天井システムリセット
        resetPityCounters()
        
        // 5. 統計データ集計
        aggregateMonthlyStatistics(month: previousMonth)
        
        // 6. 通知送信
        sendMaintenanceNotifications()
    }
    
    /// ランキング確定
    private static func finalizeRankings(month: YearMonth) {
        // 最終集計実行
        RankingAggregationSystem.updateMonthlyRankings(for: month)
        
        // 報酬配布
        RankingRewardSystem.distributeMonthlyRewards(month: month)
        
        // ランキングを確定状態に変更
        for rankingType in RankingType.allCases {
            if let ranking = DataStore.shared.getRanking(type: rankingType, month: month) {
                var finalizedRanking = ranking
                finalizedRanking.isFinalized = true
                DataStore.shared.saveRanking(finalizedRanking)
            }
        }
    }
    
    /// 新月初期化
    private static func initializeNewMonth(month: YearMonth) {
        // 新月のランキングテーブル作成
        for rankingType in RankingType.allCases {
            let emptyRanking = MonthlyRanking(
                id: UUID(),
                year: month.year,
                month: month.month,
                rankingType: rankingType,
                entries: [],
                lastUpdated: Date(),
                totalParticipants: 0,
                isFinalized: false
            )
            DataStore.shared.saveRanking(emptyRanking)
        }
        
        // 新月の統計データ初期化
        DataStore.shared.initializeMonthlyStats(month: month)
    }
    
    /// 古いデータクリーンアップ
    private static func cleanupOldData() {
        let cutoffDate = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
        let cutoffMonth = YearMonth(
            year: Calendar.current.component(.year, from: cutoffDate),
            month: Calendar.current.component(.month, from: cutoffDate)
        )
        
        // 6ヶ月より古いランキングデータを削除
        DataStore.shared.deleteOldRankings(olderThan: cutoffMonth)
        
        // 古い統計データも削除
        DataStore.shared.deleteOldMonthlyStats(olderThan: cutoffMonth)
    }
    
    /// 天井カウンターリセット
    private static func resetPityCounters() {
        if PitySystem.monthlyReset {
            DataStore.shared.resetAllPityCounters()
        }
    }
    
    /// 月次統計集計
    private static func aggregateMonthlyStatistics(month: YearMonth) {
        let allUsers = DataStore.shared.getAllUsers()
        
        var totalStats = GlobalMonthlyStats(
            totalParticipants: 0,
            totalProblems: 0,
            totalPointsEarned: 0,
            averageAccuracy: 0.0,
            topScore: 0,
            newUsers: 0,
            activeUsers: 0
        )
        
        for user in allUsers {
            let userStats = DataStore.shared.getMonthlyStats(userId: user.id, month: month)
            
            if userStats.totalProblems > 0 {
                totalStats.totalParticipants += 1
                totalStats.totalProblems += userStats.totalProblems
                totalStats.totalPointsEarned += userStats.totalPointsEarned
                
                if userStats.totalPointsEarned > totalStats.topScore {
                    totalStats.topScore = userStats.totalPointsEarned
                }
            }
            
            // 新規ユーザーチェック
            if Calendar.current.isDate(user.createdAt, equalTo: Date(), toGranularity: .month) {
                totalStats.newUsers += 1
            }
            
            // アクティブユーザーチェック（7日以内にアクティブ）
            if user.lastActiveDate.timeIntervalSinceNow > -7 * 24 * 60 * 60 {
                totalStats.activeUsers += 1
            }
        }
        
        // 平均正解率計算
        if totalStats.totalParticipants > 0 {
            let accuracySum = allUsers.compactMap { user in
                let stats = DataStore.shared.getMonthlyStats(userId: user.id, month: month)
                return stats.totalProblems > 0 ? stats.accuracy : nil
            }.reduce(0, +)
            
            totalStats.averageAccuracy = accuracySum / Double(totalStats.totalParticipants)
        }
        
        DataStore.shared.saveGlobalStats(stats: totalStats, month: month)
    }
    
    /// メンテナンス通知送信
    private static func sendMaintenanceNotifications() {
        let message = NSLocalizedString("monthly_maintenance_complete", 
            comment: "月次メンテナンスが完了しました。新しいランキングが開始されました！")
        
        NotificationService.sendGlobalNotification(
            title: NSLocalizedString("maintenance_title", comment: "メンテナンス完了"),
            body: message
        )
    }
    
    /// 現在の年月取得
    private static func getCurrentYearMonth() -> YearMonth {
        let now = Date()
        let year = Calendar.current.component(.year, from: now)
        let month = Calendar.current.component(.month, from: now)
        return YearMonth(year: year, month: month)
    }
    
    /// 緊急メンテナンス
    static func executeEmergencyMaintenance(reason: MaintenanceReason) {
        switch reason {
        case .dataCorruption:
            repairCorruptedData()
        case .securityIssue:
            implementSecurityFix()
        case .performanceIssue:
            optimizePerformance()
        case .bugFix:
            applyBugFixes()
        }
        
        // 緊急メンテナンス通知
        let message = NSLocalizedString("emergency_maintenance", 
            comment: "緊急メンテナンスを実行しました。")
        NotificationService.sendGlobalNotification(
            title: NSLocalizedString("emergency_title", comment: "緊急メンテナンス"),
            body: message
        )
    }
    
    private static func repairCorruptedData() {
        // データ修復処理
    }
    
    private static func implementSecurityFix() {
        // セキュリティ修正
    }
    
    private static func optimizePerformance() {
        // パフォーマンス最適化
    }
    
    private static func applyBugFixes() {
        // バグ修正適用
    }
}

enum MaintenanceReason {
    case dataCorruption
    case securityIssue
    case performanceIssue
    case bugFix
}

struct GlobalMonthlyStats {
    var totalParticipants: Int
    var totalProblems: Int
    var totalPointsEarned: Int
    var averageAccuracy: Double
    var topScore: Int
    var newUsers: Int
    var activeUsers: Int
}
```

この詳細仕様書により、月次ランキングシステムの完全な実装が可能になります。ランキング種別、集計システム、報酬システム、プライバシー保護、自動メンテナンスまで全て網羅されています。