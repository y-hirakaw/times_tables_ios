import SwiftUI
import SwiftData

/// バッジシステムの状態管理を担当するViewState
@MainActor
class BadgeSystemViewState: ObservableObject {
    @Published var earnedBadges: [UserBadge] = []
    @Published var newBadges: [UserBadge] = []
    @Published var showingBadgeNotification = false
    @Published var latestBadge: BadgeType?
    
    private let dataStore: DataStore
    private var currentStreak = 0
    private var fastAnswerCount = 0
    private var superFastAnswerCount = 0
    
    // 永続化用のキー
    private let currentStreakKey = "BadgeSystem_CurrentStreak"
    private let fastAnswerCountKey = "BadgeSystem_FastAnswerCount"
    private let superFastAnswerCountKey = "BadgeSystem_SuperFastAnswerCount"
    
    init(dataStore: DataStore? = nil) {
        self.dataStore = dataStore ?? DataStore.shared
        loadPersistedData()
    }
    
    /// 永続化されたデータを読み込む
    private func loadPersistedData() {
        currentStreak = UserDefaults.standard.integer(forKey: currentStreakKey)
        fastAnswerCount = UserDefaults.standard.integer(forKey: fastAnswerCountKey)
        superFastAnswerCount = UserDefaults.standard.integer(forKey: superFastAnswerCountKey)
    }
    
    /// データを永続化する
    private func persistData() {
        UserDefaults.standard.set(currentStreak, forKey: currentStreakKey)
        UserDefaults.standard.set(fastAnswerCount, forKey: fastAnswerCountKey)
        UserDefaults.standard.set(superFastAnswerCount, forKey: superFastAnswerCountKey)
    }
    
    /// 獲得済みバッジを取得
    func fetchEarnedBadges() {
        let descriptor = FetchDescriptor<UserBadge>(
            sortBy: [SortDescriptor(\.earnedDate, order: .reverse)]
        )
        do {
            earnedBadges = try dataStore.context.fetch(descriptor)
            newBadges = earnedBadges.filter { $0.isNew }
        } catch {
            print("バッジ情報の取得に失敗: \(error)")
        }
    }
    
    /// バッジを獲得
    func earnBadge(_ type: BadgeType) {
        // 既に獲得済みかチェック
        if earnedBadges.contains(where: { $0.badgeType == type.rawValue }) {
            return
        }
        
        let newBadge = UserBadge(badgeType: type)
        dataStore.context.insert(newBadge)
        
        do {
            try dataStore.context.save()
            earnedBadges.append(newBadge)
            newBadges.append(newBadge)
            
            // 通知を表示
            latestBadge = type
            showingBadgeNotification = true
            
            // 3秒後に通知を非表示
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.showingBadgeNotification = false
            }
        } catch {
            print("バッジの保存に失敗: \(error)")
        }
    }
    
    /// 新規バッジを既読にする
    func markBadgesAsRead() {
        newBadges.forEach { badge in
            badge.isNew = false
        }
        dataStore.saveContext()
        newBadges.removeAll()
    }
    
    /// 問題正解時のバッジチェック
    func checkBadgesForCorrectAnswer(
        isCorrect: Bool,
        answerTime: Double,
        totalProblems: Int,
        currentLevel: Int,
        isDifficultQuestion: Bool
    ) {
        guard isCorrect else {
            currentStreak = 0
            return
        }
        
        // 連続正解カウント
        currentStreak += 1
        checkStreakBadges()
        
        // 速度系カウント（3秒以内）
        if answerTime <= 3.0 {
            fastAnswerCount += 1
            checkSpeedBadges()
        }
        // 超高速（2秒以内）
        if answerTime <= 2.0 {
            superFastAnswerCount += 1
            checkLightningBadges()
        }
        
        // データを永続化
        persistData()
        
        // 問題数達成チェック
        checkProblemCountBadges(totalProblems)
        
        // レベル達成チェック
        checkLevelBadges(currentLevel)
    }
    
    /// 連続正解バッジのチェック
    private func checkStreakBadges() {
        switch currentStreak {
        case 10:
            earnBadge(.streak10)
        case 20:
            earnBadge(.streak20)
        case 50:
            earnBadge(.streak50)
        default:
            break
        }
    }
    
    /// 速度系バッジのチェック
    private func checkSpeedBadges() {
        if fastAnswerCount == 10 {
            earnBadge(.speedster)
        }
    }
    
    private func checkLightningBadges() {
        if superFastAnswerCount == 20 {
            earnBadge(.lightning)
        }
    }
    
    /// 問題数達成バッジのチェック
    private func checkProblemCountBadges(_ totalProblems: Int) {
        switch totalProblems {
        case 100:
            earnBadge(.problems100)
        case 500:
            earnBadge(.problems500)
        case 1000:
            earnBadge(.problems1000)
        default:
            break
        }
    }
    
    /// レベル達成バッジのチェック
    private func checkLevelBadges(_ level: Int) {
        switch level {
        case 10:
            earnBadge(.level10)
        case 25:
            earnBadge(.level25)
        case 50:
            earnBadge(.level50)
        default:
            break
        }
    }
    
    /// 段マスターバッジのチェック
    func checkTableMasterBadges(masteredTables: Int) {
        if masteredTables == 1 && !hasBadge(.tableMaster) {
            earnBadge(.tableMaster)
        }
        if masteredTables == 9 && !hasBadge(.allTableMaster) {
            earnBadge(.allTableMaster)
        }
    }
    
    /// デイリー達成バッジのチェック
    func checkDailyBadges(streakDays: Int) {
        if streakDays == 7 && !hasBadge(.dailyChampion) {
            earnBadge(.dailyChampion)
        }
        if streakDays == 30 && !hasBadge(.weeklyWarrior) {
            earnBadge(.weeklyWarrior)
        }
    }
    
    /// 苦手克服バッジのチェック
    func checkOvercomeBadges(improvedCount: Int) {
        if improvedCount >= 5 && !hasBadge(.overcomer) {
            earnBadge(.overcomer)
        }
        if improvedCount >= 10 && !hasBadge(.conqueror) {
            earnBadge(.conqueror)
        }
    }
    
    /// 特定のバッジを持っているかチェック
    private func hasBadge(_ type: BadgeType) -> Bool {
        return earnedBadges.contains { $0.badgeType == type.rawValue }
    }
    
    /// 不正解時の処理
    func handleIncorrectAnswer() {
        currentStreak = 0
        persistData()
    }
    
    /// 獲得済みバッジの数
    var earnedBadgeCount: Int {
        earnedBadges.count
    }
    
    /// 全バッジ数
    var totalBadgeCount: Int {
        BadgeType.allCases.count
    }
    
    /// 進捗率
    var progressPercentage: Double {
        guard totalBadgeCount > 0 else { return 0 }
        return Double(earnedBadgeCount) / Double(totalBadgeCount) * 100
    }
    
    /// デバッグ用：テストバッジを強制的に獲得
    func debugEarnTestBadge() {
        earnBadge(.streak10)
    }
}