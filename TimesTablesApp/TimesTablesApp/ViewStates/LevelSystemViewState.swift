import SwiftUI
import SwiftData

/// レベルシステムの状態管理を担当するViewState
@MainActor
class LevelSystemViewState: ObservableObject {
    @Published var userLevel: UserLevel?
    @Published var isLevelingUp = false
    @Published var levelUpInfo: LevelUpInfo?
    
    private let dataStore: DataStore
    
    struct LevelUpInfo {
        let fromLevel: Int
        let toLevel: Int
        let newTitle: String
        let experienceGained: Int
    }
    
    init(dataStore: DataStore? = nil) {
        self.dataStore = dataStore ?? DataStore.shared
        // 初期化直後にfetchを呼ぶのではなく、必要に応じて呼び出すように変更
    }
    
    /// ユーザーレベル情報を取得
    func fetchUserLevel() {
        let descriptor = FetchDescriptor<UserLevel>()
        do {
            if let level = try dataStore.context.fetch(descriptor).first {
                self.userLevel = level
                // データが更新されたことを通知
                objectWillChange.send()
            } else {
                print("ユーザーレベル情報が見つかりません")
            }
        } catch {
            print("ユーザーレベル情報の取得に失敗: \(error)")
        }
    }
    
    /// ポイント獲得時にレベルを更新
    func updateLevelWithPoints() {
        guard let currentLevel = userLevel else { return }
        
        // 最新のポイント情報を取得
        let pointsDescriptor = FetchDescriptor<UserPoints>()
        do {
            if let userPoints = try dataStore.context.fetch(pointsDescriptor).first {
                let previousLevel = currentLevel.currentLevel
                let result = currentLevel.updateExperience(userPoints.totalEarnedPoints)
                
                if result.didLevelUp, let newLevel = result.newLevel {
                    // レベルアップ！
                    isLevelingUp = true
                    levelUpInfo = LevelUpInfo(
                        fromLevel: previousLevel,
                        toLevel: newLevel,
                        newTitle: currentLevel.getTitleForLevel(newLevel),
                        experienceGained: userPoints.totalEarnedPoints
                    )
                    
                    // データを保存
                    dataStore.saveContext()
                    
                    // レベルアップアニメーションを表示
                    showLevelUpAnimation()
                }
            }
        } catch {
            print("ポイント情報の取得に失敗: \(error)")
        }
    }
    
    /// レベルアップアニメーションを表示
    private func showLevelUpAnimation() {
        // 3秒後にアニメーションを非表示
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.isLevelingUp = false
            self.levelUpInfo = nil
        }
    }
    
    /// 現在のレベル
    var currentLevel: Int {
        if userLevel == nil {
            fetchUserLevel()
        }
        return userLevel?.currentLevel ?? 1
    }
    
    /// 現在の称号
    var currentTitle: String {
        if userLevel == nil {
            fetchUserLevel()
        }
        // データベースの値ではなく、現在のレベルから動的に称号を取得
        return userLevel?.getTitleForLevel(userLevel?.currentLevel ?? 1) ?? "九九みならい"
    }
    
    /// 現在の経験値
    var currentExperience: Int {
        if userLevel == nil {
            fetchUserLevel()
        }
        return userLevel?.totalExperience ?? 0
    }
    
    /// 次のレベルまでの経験値
    var experienceToNextLevel: Int {
        if userLevel == nil {
            fetchUserLevel()
        }
        return userLevel?.experienceToNextLevel ?? 0
    }
    
    /// 現在のレベル進捗（0.0〜1.0）
    var currentLevelProgress: Double {
        if userLevel == nil {
            fetchUserLevel()
        }
        return userLevel?.currentLevelProgress ?? 0.0
    }
    
    /// 次のレベルに必要な総経験値
    var experienceRequiredForNextLevel: Int {
        if userLevel == nil {
            fetchUserLevel()
        }
        return userLevel?.experienceRequiredForNextLevel ?? 0
    }
    
    /// レベルアップ履歴
    var levelUpHistory: [UserLevel.LevelUpRecord] {
        if userLevel == nil {
            fetchUserLevel()
        }
        return userLevel?.levelUpHistory ?? []
    }
}