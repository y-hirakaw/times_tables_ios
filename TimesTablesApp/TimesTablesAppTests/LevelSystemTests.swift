import Testing
@testable import TimesTablesApp
import SwiftData

/// レベルシステムの動作をテストするクラス
@MainActor
struct LevelSystemTests {
    
    /// UserLevelモデルの基本機能をテスト
    @Test
    func testUserLevelBasicFunctionality() async throws {
        let userLevel = UserLevel()
        
        // 初期値の確認
        #expect(userLevel.currentLevel == 1)
        #expect(userLevel.currentExperience == 0)
        #expect(userLevel.totalExperience == 0)
        #expect(userLevel.currentTitle == NSLocalizedString("level_title_beginner", tableName: "Gamification", comment: "九九みならい"))
        #expect(userLevel.levelUpHistory.isEmpty)
    }
    
    /// 経験値からレベル計算をテスト
    @Test
    func testExperienceToLevelCalculation() async throws {
        // レベル1（0 EXP）
        let level1 = UserLevel.calculateLevelFromExperience(0)
        #expect(level1 == 1)
        
        // レベル2（10 EXP）
        let level2 = UserLevel.calculateLevelFromExperience(10)
        #expect(level2 == 2)
        
        // レベル3（25 EXP）
        let level3 = UserLevel.calculateLevelFromExperience(25)
        #expect(level3 == 3)
        
        // レベル4（45 EXP）
        let level4 = UserLevel.calculateLevelFromExperience(45)
        #expect(level4 == 4)
        
        // レベル5（70 EXP）
        let level5 = UserLevel.calculateLevelFromExperience(70)
        #expect(level5 == 5)
    }
    
    /// 必要経験値計算をテスト
    @Test
    func testExperienceRequiredForLevel() async throws {
        // レベル1: 0 EXP
        let level1Exp = UserLevel.experienceRequiredForLevel(1)
        #expect(level1Exp == 0)
        
        // レベル2: 10 EXP
        let level2Exp = UserLevel.experienceRequiredForLevel(2)
        #expect(level2Exp == 10)
        
        // レベル3: 25 EXP
        let level3Exp = UserLevel.experienceRequiredForLevel(3)
        #expect(level3Exp == 25)
        
        // レベル4: 45 EXP
        let level4Exp = UserLevel.experienceRequiredForLevel(4)
        #expect(level4Exp == 45)
        
        // レベル5: 70 EXP
        let level5Exp = UserLevel.experienceRequiredForLevel(5)
        #expect(level5Exp == 70)
    }
    
    /// レベルアップ機能をテスト
    @Test
    func testLevelUp() async throws {
        let userLevel = UserLevel()
        
        // レベル1から2にアップ
        let result1 = userLevel.updateExperience(15)
        #expect(result1.didLevelUp == true)
        #expect(result1.newLevel == 2)
        #expect(userLevel.currentLevel == 2)
        #expect(userLevel.totalExperience == 15)
        
        // レベル2から3にアップ
        let result2 = userLevel.updateExperience(30)
        #expect(result2.didLevelUp == true)
        #expect(result2.newLevel == 3)
        #expect(userLevel.currentLevel == 3)
        #expect(userLevel.totalExperience == 30)
        
        // レベルアップ履歴の確認
        #expect(userLevel.levelUpHistory.count == 2)
        #expect(userLevel.levelUpHistory[0].fromLevel == 1)
        #expect(userLevel.levelUpHistory[0].toLevel == 2)
        #expect(userLevel.levelUpHistory[1].fromLevel == 2)
        #expect(userLevel.levelUpHistory[1].toLevel == 3)
    }
    
    /// 称号システムをテスト
    @Test
    func testTitleSystem() async throws {
        let userLevel = UserLevel()
        
        // 各レベルの称号を確認
        #expect(userLevel.getTitleForLevel(1) == NSLocalizedString("level_title_beginner", tableName: "Gamification", comment: "九九みならい"))
        #expect(userLevel.getTitleForLevel(6) == NSLocalizedString("level_title_apprentice", tableName: "Gamification", comment: "九九れんしゅうせい"))
        #expect(userLevel.getTitleForLevel(11) == NSLocalizedString("level_title_practitioner", tableName: "Gamification", comment: "九九じゅくれんしゃ"))
        #expect(userLevel.getTitleForLevel(21) == NSLocalizedString("level_title_expert", tableName: "Gamification", comment: "九九めいじん"))
        #expect(userLevel.getTitleForLevel(31) == NSLocalizedString("level_title_master", tableName: "Gamification", comment: "九九マスター"))
        #expect(userLevel.getTitleForLevel(41) == NSLocalizedString("level_title_grandmaster", tableName: "Gamification", comment: "九九グランドマスター"))
        #expect(userLevel.getTitleForLevel(50) == NSLocalizedString("level_title_legend", tableName: "Gamification", comment: "九九レジェンド"))
    }
    
    /// レベル進捗計算をテスト
    @Test
    func testLevelProgress() async throws {
        let userLevel = UserLevel()
        
        // レベル1で経験値5（レベル2まで10必要）
        userLevel.updateExperience(5)
        
        // 進捗率は50%になるはず
        let progress = userLevel.currentLevelProgress
        #expect(progress == 0.5)
        
        // 次のレベルまでの経験値
        let expToNext = userLevel.experienceToNextLevel
        #expect(expToNext == 5)
    }
    
    /// LevelSystemViewStateの基本機能をテスト
    @Test
    func testLevelSystemViewState() async throws {
        let levelSystem = LevelSystemViewState()
        
        // 初期状態の確認
        #expect(levelSystem.currentLevel == 1)
        #expect(levelSystem.currentExperience == 0)
        #expect(levelSystem.experienceToNextLevel >= 0)
        #expect(levelSystem.currentLevelProgress >= 0.0)
        #expect(levelSystem.currentLevelProgress <= 1.0)
        
        // 称号の確認
        #expect(levelSystem.currentTitle == NSLocalizedString("level_title_beginner", tableName: "Gamification", comment: "九九みならい"))
    }
}