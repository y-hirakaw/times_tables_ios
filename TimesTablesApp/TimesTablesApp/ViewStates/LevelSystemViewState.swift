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
        fetchUserLevel()
    }
    
    /// ユーザーレベル情報を取得
    func fetchUserLevel() {
        let descriptor = FetchDescriptor<UserLevel>()
        do {
            if let level = try dataStore.context.fetch(descriptor).first {
                self.userLevel = level
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
                        newTitle: currentLevel.currentTitle,
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
        userLevel?.currentLevel ?? 1
    }
    
    /// 現在の称号
    var currentTitle: String {
        userLevel?.currentTitle ?? NSLocalizedString("level_title_beginner", comment: "九九みならい")
    }
    
    /// 現在の経験値
    var currentExperience: Int {
        userLevel?.totalExperience ?? 0
    }
    
    /// 次のレベルまでの経験値
    var experienceToNextLevel: Int {
        userLevel?.experienceToNextLevel ?? 0
    }
    
    /// 現在のレベル進捗（0.0〜1.0）
    var currentLevelProgress: Double {
        userLevel?.currentLevelProgress ?? 0.0
    }
    
    /// 次のレベルに必要な総経験値
    var experienceRequiredForNextLevel: Int {
        userLevel?.experienceRequiredForNextLevel ?? 0
    }
    
    /// レベルアップ履歴
    var levelUpHistory: [UserLevel.LevelUpRecord] {
        userLevel?.levelUpHistory ?? []
    }
}