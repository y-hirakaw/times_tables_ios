# キャラクター進化＆ルームカスタマイズシステム 詳細仕様書

## 1. キャラクター進化システム

### 1.1 スターターキャラクター詳細仕様

#### 1.1.1 くくのき（植物型）キャラクター
```swift
enum TreeEvolutionStage: Int, CaseIterable {
    case seed = 1      // たね (Lv.1-9)
    case sprout = 2    // めばえ (Lv.10-24)
    case sapling = 3   // わかぎ (Lv.25-39)
    case tree = 4      // たいぼく (Lv.40-49)
    case sacred = 5    // せいれいじゅ (Lv.50)
    
    var displayName: String {
        switch self {
        case .seed: return NSLocalizedString("seed", comment: "たね")
        case .sprout: return NSLocalizedString("sprout", comment: "めばえ")
        case .sapling: return NSLocalizedString("sapling", comment: "わかぎ")
        case .tree: return NSLocalizedString("tree", comment: "たいぼく")
        case .sacred: return NSLocalizedString("sacred_tree", comment: "せいれいじゅ")
        }
    }
    
    var assetName: String {
        return "tree_stage_\(rawValue)"
    }
    
    // 季節変化（春夏秋冬で見た目変化）
    func seasonalAssetName(season: Season) -> String {
        if self.rawValue >= 3 { // わかぎ以降で季節変化
            return "tree_stage_\(rawValue)_\(season.rawValue)"
        }
        return assetName
    }
}

enum Season: String, CaseIterable {
    case spring = "spring"  // 春：新緑
    case summer = "summer"  // 夏：濃緑
    case autumn = "autumn"  // 秋：紅葉
    case winter = "winter"  // 冬：枯れ枝
}
```

#### 1.1.2 すうじぼし（宇宙型）キャラクター
```swift
enum StarEvolutionStage: Int, CaseIterable {
    case particle = 1    // ひかりのつぶ (Lv.1-9)
    case smallStar = 2   // ちいさなほし (Lv.10-24)
    case shiningStar = 3 // きらぼし (Lv.25-39)
    case meteor = 4      // りゅうせい (Lv.40-49)
    case galaxy = 5      // ぎんがのほし (Lv.50)
    
    var displayName: String {
        switch self {
        case .particle: return NSLocalizedString("light_particle", comment: "ひかりのつぶ")
        case .smallStar: return NSLocalizedString("small_star", comment: "ちいさなほし")
        case .shiningStar: return NSLocalizedString("shining_star", comment: "きらぼし")
        case .meteor: return NSLocalizedString("meteor", comment: "りゅうせい")
        case .galaxy: return NSLocalizedString("galaxy_star", comment: "ぎんがのほし")
        }
    }
    
    // エフェクト強度（レベルが上がるほど光る）
    var glowIntensity: Double {
        return Double(rawValue) * 0.2
    }
    
    // 周回する小星の数
    var orbitingStarsCount: Int {
        return max(0, rawValue - 1)
    }
}
```

#### 1.1.3 けいさんロボ（メカ型）キャラクター
```swift
enum RobotEvolutionStage: Int, CaseIterable {
    case miniRobot = 1     // ミニロボ (Lv.1-9)
    case learningRobot = 2 // まなびロボ (Lv.10-24)
    case smartRobot = 3    // かしこロボ (Lv.25-39)
    case superRobot = 4    // スーパーロボ (Lv.40-49)
    case legendRobot = 5   // でんせつロボ (Lv.50)
    
    var displayName: String {
        switch self {
        case .miniRobot: return NSLocalizedString("mini_robot", comment: "ミニロボ")
        case .learningRobot: return NSLocalizedString("learning_robot", comment: "まなびロボ")
        case .smartRobot: return NSLocalizedString("smart_robot", comment: "かしこロボ")
        case .superRobot: return NSLocalizedString("super_robot", comment: "スーパーロボ")
        case .legendRobot: return NSLocalizedString("legend_robot", comment: "でんせつロボ")
        }
    }
    
    // 計算時の光る箇所数
    var lightUpPartsCount: Int {
        return rawValue * 2
    }
    
    // 動作の滑らかさ（レベルが上がるほど滑らか）
    var movementSmoothness: Double {
        return min(1.0, Double(rawValue) * 0.15 + 0.25)
    }
}
```

### 1.2 進化判定ロジック

```swift
class CharacterEvolutionManager {
    
    /// レベルに基づいて進化段階を計算
    static func getEvolutionStage(for characterType: CharacterType, level: Int) -> Int {
        switch level {
        case 1...9: return 1
        case 10...24: return 2
        case 25...39: return 3
        case 40...49: return 4
        case 50...: return 5
        default: return 1
        }
    }
    
    /// 進化可能かチェック
    static func canEvolve(character: StarterCharacter, newLevel: Int) -> Bool {
        let currentStage = getEvolutionStage(for: character.characterType, level: character.currentLevel)
        let newStage = getEvolutionStage(for: character.characterType, level: newLevel)
        return newStage > currentStage
    }
    
    /// 特別進化条件チェック（全段マスター時）
    static func checkSpecialEvolution(character: StarterCharacter) -> Bool {
        let masteryProgress = DataStore.shared.getAllMasteryProgress()
        let allMastered = masteryProgress.allSatisfy { $0.masteryLevel == .master }
        return allMastered && character.currentLevel >= 50
    }
    
    /// レア個体判定（0.1%確率）
    static func checkRareVariant() -> Bool {
        return Double.random(in: 0...1) < 0.001
    }
}
```

### 1.3 進化演出システム

```swift
class EvolutionAnimationController {
    
    /// 進化アニメーション実行
    static func playEvolutionAnimation(
        for character: StarterCharacter,
        from oldStage: Int,
        to newStage: Int,
        completion: @escaping () -> Void
    ) {
        // 1. 光エフェクト開始
        playLightEffect(duration: 2.0)
        
        // 2. キャラクター隠す
        hideCharacter(delay: 0.5)
        
        // 3. 進化メッセージ表示
        showEvolutionMessage(character: character, newStage: newStage, delay: 1.0)
        
        // 4. 新しいキャラクター登場
        revealNewCharacter(character: character, newStage: newStage, delay: 3.0)
        
        // 5. 祝福エフェクト
        playCelebrationEffect(delay: 4.0)
        
        // 6. 完了コールバック
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            completion()
        }
    }
    
    private static func playLightEffect(duration: Double) {
        // 画面全体を光らせるエフェクト
    }
    
    private static func hideCharacter(delay: Double) {
        // キャラクターを光に包んで隠す
    }
    
    private static func showEvolutionMessage(character: StarterCharacter, newStage: Int, delay: Double) {
        // "○○が△△に進化した！" メッセージ表示
    }
    
    private static func revealNewCharacter(character: StarterCharacter, newStage: Int, delay: Double) {
        // 新しい姿のキャラクターを登場させる
    }
    
    private static func playCelebrationEffect(delay: Double) {
        // 花火や星などの祝福エフェクト
    }
}
```

## 2. ルームカスタマイズシステム

### 2.1 ルームアイテム詳細仕様

```swift
enum RoomItemCategory: String, CaseIterable {
    case floor = "floor"
    case wallpaper = "wallpaper"
    case furniture = "furniture"
    case decoration = "decoration"
    case special = "special"
    
    var displayName: String {
        switch self {
        case .floor: return NSLocalizedString("floor", comment: "床")
        case .wallpaper: return NSLocalizedString("wallpaper", comment: "壁紙")
        case .furniture: return NSLocalizedString("furniture", comment: "家具")
        case .decoration: return NSLocalizedString("decoration", comment: "装飾品")
        case .special: return NSLocalizedString("special_items", comment: "特別アイテム")
        }
    }
}

struct RoomItemData {
    let id: String
    let name: String
    let category: RoomItemCategory
    let price: Int
    let assetName: String
    let unlockRequirement: UnlockRequirement?
    let interactionType: InteractionType?
    let size: CGSize
    let description: String
    
    enum UnlockRequirement {
        case level(Int)
        case masteryComplete(table: Int)
        case allMasteryComplete
        case pointsEarned(Int)
        case rankingPosition(rank: Int, month: String)
        case badge(String)
    }
    
    enum InteractionType {
        case sit        // 座る
        case read       // 読書
        case watch      // 見る
        case play       // 遊ぶ
        case sleep      // 休む
        case study      // 勉強
    }
}
```

### 2.2 ルームアイテム全一覧

```swift
class RoomItemDatabase {
    static let allItems: [RoomItemData] = [
        // 床材 (5-15pt)
        RoomItemData(
            id: "floor_wood",
            name: NSLocalizedString("wooden_floor", comment: "木の床"),
            category: .floor,
            price: 5,
            assetName: "floor_wood",
            unlockRequirement: nil,
            interactionType: nil,
            size: CGSize(width: 320, height: 240),
            description: NSLocalizedString("wooden_floor_desc", comment: "あたたかみのある木の床です")
        ),
        RoomItemData(
            id: "floor_carpet",
            name: NSLocalizedString("carpet_floor", comment: "カーペット"),
            category: .floor,
            price: 8,
            assetName: "floor_carpet",
            unlockRequirement: nil,
            interactionType: nil,
            size: CGSize(width: 320, height: 240),
            description: NSLocalizedString("carpet_floor_desc", comment: "ふわふわで気持ちいいカーペットです")
        ),
        RoomItemData(
            id: "floor_tatami",
            name: NSLocalizedString("tatami_floor", comment: "たたみ"),
            category: .floor,
            price: 10,
            assetName: "floor_tatami",
            unlockRequirement: nil,
            interactionType: nil,
            size: CGSize(width: 320, height: 240),
            description: NSLocalizedString("tatami_floor_desc", comment: "和風のたたみの床です")
        ),
        RoomItemData(
            id: "floor_cloud",
            name: NSLocalizedString("cloud_floor", comment: "雲の床"),
            category: .floor,
            price: 15,
            assetName: "floor_cloud",
            unlockRequirement: .level(20),
            interactionType: nil,
            size: CGSize(width: 320, height: 240),
            description: NSLocalizedString("cloud_floor_desc", comment: "雲の上を歩いているみたい！")
        ),
        
        // 壁紙 (8-15pt)
        RoomItemData(
            id: "wall_starry",
            name: NSLocalizedString("starry_wallpaper", comment: "星空の壁紙"),
            category: .wallpaper,
            price: 10,
            assetName: "wall_starry",
            unlockRequirement: nil,
            interactionType: nil,
            size: CGSize(width: 320, height: 180),
            description: NSLocalizedString("starry_wallpaper_desc", comment: "きれいな星空の壁紙です")
        ),
        RoomItemData(
            id: "wall_forest",
            name: NSLocalizedString("forest_wallpaper", comment: "森の壁紙"),
            category: .wallpaper,
            price: 12,
            assetName: "wall_forest",
            unlockRequirement: nil,
            interactionType: nil,
            size: CGSize(width: 320, height: 180),
            description: NSLocalizedString("forest_wallpaper_desc", comment: "緑いっぱいの森の壁紙です")
        ),
        
        // 家具 (10-30pt)
        RoomItemData(
            id: "furniture_desk",
            name: NSLocalizedString("study_desk", comment: "勉強机"),
            category: .furniture,
            price: 10,
            assetName: "furniture_desk",
            unlockRequirement: nil,
            interactionType: .study,
            size: CGSize(width: 60, height: 40),
            description: NSLocalizedString("study_desk_desc", comment: "九九の勉強をするための机です")
        ),
        RoomItemData(
            id: "furniture_bookshelf",
            name: NSLocalizedString("bookshelf", comment: "本棚"),
            category: .furniture,
            price: 15,
            assetName: "furniture_bookshelf",
            unlockRequirement: nil,
            interactionType: .read,
            size: CGSize(width: 50, height: 80),
            description: NSLocalizedString("bookshelf_desc", comment: "たくさんの本が入った本棚です")
        ),
        RoomItemData(
            id: "furniture_sofa",
            name: NSLocalizedString("sofa", comment: "ソファー"),
            category: .furniture,
            price: 20,
            assetName: "furniture_sofa",
            unlockRequirement: nil,
            interactionType: .sit,
            size: CGSize(width: 80, height: 50),
            description: NSLocalizedString("sofa_desc", comment: "ゆっくりくつろげるソファーです")
        ),
        RoomItemData(
            id: "furniture_tv",
            name: NSLocalizedString("television", comment: "テレビ"),
            category: .furniture,
            price: 25,
            assetName: "furniture_tv",
            unlockRequirement: .level(15),
            interactionType: .watch,
            size: CGSize(width: 70, height: 50),
            description: NSLocalizedString("television_desc", comment: "楽しい番組が見られるテレビです")
        ),
        RoomItemData(
            id: "furniture_piano",
            name: NSLocalizedString("piano", comment: "ピアノ"),
            category: .furniture,
            price: 30,
            assetName: "furniture_piano",
            unlockRequirement: .level(25),
            interactionType: .play,
            size: CGSize(width: 90, height: 60),
            description: NSLocalizedString("piano_desc", comment: "美しい音色のピアノです")
        ),
        
        // 装飾品 (5-20pt)
        RoomItemData(
            id: "deco_poster_kuuku",
            name: NSLocalizedString("times_table_poster", comment: "九九ポスター"),
            category: .decoration,
            price: 5,
            assetName: "deco_poster_kuuku",
            unlockRequirement: nil,
            interactionType: nil,
            size: CGSize(width: 40, height: 60),
            description: NSLocalizedString("times_table_poster_desc", comment: "九九を覚えるためのポスターです")
        ),
        RoomItemData(
            id: "deco_clock",
            name: NSLocalizedString("wall_clock", comment: "時計"),
            category: .decoration,
            price: 10,
            assetName: "deco_clock",
            unlockRequirement: nil,
            interactionType: nil,
            size: CGSize(width: 30, height: 30),
            description: NSLocalizedString("wall_clock_desc", comment: "時間を教えてくれる時計です")
        ),
        RoomItemData(
            id: "deco_trophy",
            name: NSLocalizedString("gold_trophy", comment: "トロフィー"),
            category: .decoration,
            price: 15,
            assetName: "deco_trophy",
            unlockRequirement: .masteryComplete(table: 1),
            interactionType: nil,
            size: CGSize(width: 25, height: 40),
            description: NSLocalizedString("gold_trophy_desc", comment: "がんばった証のトロフィーです")
        ),
        RoomItemData(
            id: "deco_plushie",
            name: NSLocalizedString("cute_plushie", comment: "ぬいぐるみ"),
            category: .decoration,
            price: 12,
            assetName: "deco_plushie",
            unlockRequirement: nil,
            interactionType: .play,
            size: CGSize(width: 35, height: 40),
            description: NSLocalizedString("cute_plushie_desc", comment: "かわいいぬいぐるみです")
        ),
        RoomItemData(
            id: "deco_aquarium",
            name: NSLocalizedString("fish_tank", comment: "水槽"),
            category: .decoration,
            price: 20,
            assetName: "deco_aquarium",
            unlockRequirement: .level(20),
            interactionType: .watch,
            size: CGSize(width: 60, height: 50),
            description: NSLocalizedString("fish_tank_desc", comment: "きれいな魚が泳ぐ水槽です")
        ),
        
        // 特別アイテム（獲得条件あり）
        RoomItemData(
            id: "special_mastery_trophy_1",
            name: NSLocalizedString("first_table_trophy", comment: "1の段マスタートロフィー"),
            category: .special,
            price: 0,
            assetName: "special_trophy_1",
            unlockRequirement: .masteryComplete(table: 1),
            interactionType: nil,
            size: CGSize(width: 30, height: 45),
            description: NSLocalizedString("first_table_trophy_desc", comment: "1の段をマスターした証です")
        ),
        // ... 各段のトロフィー（2-9の段）
        RoomItemData(
            id: "special_rainbow_fountain",
            name: NSLocalizedString("rainbow_fountain", comment: "虹の噴水"),
            category: .special,
            price: 0,
            assetName: "special_rainbow_fountain",
            unlockRequirement: .allMasteryComplete,
            interactionType: .watch,
            size: CGSize(width: 80, height: 100),
            description: NSLocalizedString("rainbow_fountain_desc", comment: "全段マスターの偉大な証です")
        ),
        RoomItemData(
            id: "special_golden_frame",
            name: NSLocalizedString("golden_frame", comment: "金の額縁"),
            category: .special,
            price: 0,
            assetName: "special_golden_frame",
            unlockRequirement: .rankingPosition(rank: 1, month: "current"),
            interactionType: nil,
            size: CGSize(width: 50, height: 60),
            description: NSLocalizedString("golden_frame_desc", comment: "月間ランキング1位の証です")
        ),
        RoomItemData(
            id: "special_legend_stone",
            name: NSLocalizedString("legend_stone", comment: "伝説の石碑"),
            category: .special,
            price: 0,
            assetName: "special_legend_stone",
            unlockRequirement: .pointsEarned(10000),
            interactionType: nil,
            size: CGSize(width: 60, height: 80),
            description: NSLocalizedString("legend_stone_desc", comment: "10,000問正解の偉業を刻んだ石碑です")
        )
    ]
}
```

### 2.3 キャラクター・ルーム相互作用システム

```swift
class CharacterRoomInteractionManager {
    
    /// キャラクターの行動パターン決定
    static func determineCharacterAction(
        character: StarterCharacter,
        room: CharacterRoom,
        timeOfDay: TimeOfDay
    ) -> CharacterAction {
        
        let availableInteractions = getAvailableInteractions(room: room)
        
        // 時間帯による基本行動
        switch timeOfDay {
        case .morning:
            return chooseFromActions([.study, .read, .walk], availableInteractions: availableInteractions)
        case .afternoon:
            return chooseFromActions([.play, .watch, .sit], availableInteractions: availableInteractions)
        case .evening:
            return chooseFromActions([.sit, .watch, .read], availableInteractions: availableInteractions)
        case .night:
            return chooseFromActions([.sleep, .sit], availableInteractions: availableInteractions)
        }
    }
    
    /// ルーム内の利用可能な相互作用を取得
    static func getAvailableInteractions(room: CharacterRoom) -> [InteractionType] {
        var interactions: [InteractionType] = [.walk] // 常に歩ける
        
        for furniture in room.furniture {
            if let item = RoomItemDatabase.allItems.first(where: { $0.id == furniture.id }),
               let interaction = item.interactionType {
                interactions.append(interaction)
            }
        }
        
        for decoration in room.decorations {
            if let item = RoomItemDatabase.allItems.first(where: { $0.id == decoration.id }),
               let interaction = item.interactionType {
                interactions.append(interaction)
            }
        }
        
        return interactions
    }
    
    /// 行動選択ロジック
    static func chooseFromActions(
        _ preferredActions: [CharacterAction],
        availableInteractions: [InteractionType]
    ) -> CharacterAction {
        
        for action in preferredActions {
            if availableInteractions.contains(action.requiredInteraction) {
                return action
            }
        }
        
        return .walk // デフォルトは歩き回る
    }
    
    /// ボーナスエフェクト判定
    static func checkRoomBonusEffects(room: CharacterRoom) -> [RoomBonus] {
        var bonuses: [RoomBonus] = []
        
        // 勉強机 + 本棚の組み合わせ
        if hasItem(room: room, itemId: "furniture_desk") && hasItem(room: room, itemId: "furniture_bookshelf") {
            bonuses.append(.studyBonus(multiplier: 1.1))
        }
        
        // ソファー + テレビの組み合わせ
        if hasItem(room: room, itemId: "furniture_sofa") && hasItem(room: room, itemId: "furniture_tv") {
            bonuses.append(.relaxationBonus)
        }
        
        // 全段マスタートロフィー5個以上
        let masteryTrophies = room.decorations.filter { $0.id.contains("mastery_trophy") }
        if masteryTrophies.count >= 5 {
            bonuses.append(.masteryPrideBonus(multiplier: 1.05))
        }
        
        return bonuses
    }
    
    private static func hasItem(room: CharacterRoom, itemId: String) -> Bool {
        return room.furniture.contains { $0.id == itemId } ||
               room.decorations.contains { $0.id == itemId }
    }
}

enum TimeOfDay {
    case morning   // 6:00-12:00
    case afternoon // 12:00-18:00
    case evening   // 18:00-22:00
    case night     // 22:00-6:00
}

enum CharacterAction {
    case walk
    case study
    case read
    case sit
    case watch
    case play
    case sleep
    
    var requiredInteraction: InteractionType {
        switch self {
        case .walk: return .walk
        case .study: return .study
        case .read: return .read
        case .sit: return .sit
        case .watch: return .watch
        case .play: return .play
        case .sleep: return .sleep
        }
    }
    
    var animationDuration: Double {
        switch self {
        case .walk: return 10.0
        case .study: return 30.0
        case .read: return 25.0
        case .sit: return 20.0
        case .watch: return 35.0
        case .play: return 15.0
        case .sleep: return 60.0
        }
    }
}

enum RoomBonus {
    case studyBonus(multiplier: Double)
    case relaxationBonus
    case masteryPrideBonus(multiplier: Double)
    
    var description: String {
        switch self {
        case .studyBonus(let multiplier):
            return NSLocalizedString("study_bonus", comment: "勉強効率+\(Int((multiplier - 1) * 100))%")
        case .relaxationBonus:
            return NSLocalizedString("relaxation_bonus", comment: "キャラクターがリラックスしています")
        case .masteryPrideBonus(let multiplier):
            return NSLocalizedString("mastery_pride_bonus", comment: "達成感ボーナス+\(Int((multiplier - 1) * 100))%")
        }
    }
}
```

### 2.4 ルーム配置システム

```swift
class RoomLayoutManager {
    
    /// アイテム配置可能位置計算
    static func getPlaceablePositions(
        for item: RoomItemData,
        in room: CharacterRoom,
        roomSize: CGSize = CGSize(width: 320, height: 240)
    ) -> [CGPoint] {
        
        var positions: [CGPoint] = []
        let gridSize: CGFloat = 10
        
        for x in stride(from: 0, to: roomSize.width - item.size.width, by: gridSize) {
            for y in stride(from: 0, to: roomSize.height - item.size.height, by: gridSize) {
                let position = CGPoint(x: x, y: y)
                if canPlaceItem(item: item, at: position, in: room, roomSize: roomSize) {
                    positions.append(position)
                }
            }
        }
        
        return positions
    }
    
    /// アイテム配置可能性チェック
    static func canPlaceItem(
        item: RoomItemData,
        at position: CGPoint,
        in room: CharacterRoom,
        roomSize: CGSize
    ) -> Bool {
        
        let itemRect = CGRect(origin: position, size: item.size)
        
        // 部屋の境界チェック
        let roomRect = CGRect(origin: .zero, size: roomSize)
        if !roomRect.contains(itemRect) {
            return false
        }
        
        // 既存アイテムとの衝突チェック
        for existingFurniture in room.furniture {
            if let existingItem = RoomItemDatabase.allItems.first(where: { $0.id == existingFurniture.id }),
               let existingPosition = existingFurniture.position {
                let existingRect = CGRect(origin: existingPosition, size: existingItem.size)
                if itemRect.intersects(existingRect) {
                    return false
                }
            }
        }
        
        for existingDecoration in room.decorations {
            if let existingItem = RoomItemDatabase.allItems.first(where: { $0.id == existingDecoration.id }),
               let existingPosition = existingDecoration.position {
                let existingRect = CGRect(origin: existingPosition, size: existingItem.size)
                if itemRect.intersects(existingRect) {
                    return false
                }
            }
        }
        
        // カテゴリ固有のルール
        switch item.category {
        case .floor, .wallpaper:
            return true // 床と壁紙は常に配置可能
        case .furniture:
            return checkFurniturePlacementRules(item: item, position: position, roomSize: roomSize)
        case .decoration:
            return checkDecorationPlacementRules(item: item, position: position, roomSize: roomSize)
        case .special:
            return true
        }
    }
    
    private static func checkFurniturePlacementRules(
        item: RoomItemData,
        position: CGPoint,
        roomSize: CGSize
    ) -> Bool {
        // 大型家具は壁際に配置
        if item.size.width > 70 || item.size.height > 70 {
            let margin: CGFloat = 20
            return position.x < margin || 
                   position.x > roomSize.width - item.size.width - margin ||
                   position.y < margin || 
                   position.y > roomSize.height - item.size.height - margin
        }
        return true
    }
    
    private static func checkDecorationPlacementRules(
        item: RoomItemData,
        position: CGPoint,
        roomSize: CGSize
    ) -> Bool {
        // 装飾品は部屋の中央部は避ける
        let centerRect = CGRect(
            x: roomSize.width * 0.3,
            y: roomSize.height * 0.3,
            width: roomSize.width * 0.4,
            height: roomSize.height * 0.4
        )
        let itemRect = CGRect(origin: position, size: item.size)
        return !centerRect.intersects(itemRect)
    }
}
```

### 2.5 ルームテーマ自動判定システム

```swift
class RoomThemeDetector {
    
    enum RoomTheme: String, CaseIterable {
        case study = "study"           // 勉強部屋
        case relaxation = "relaxation" // くつろぎ部屋
        case nature = "nature"         // 自然部屋
        case technology = "tech"       // テクノロジー部屋
        case achievement = "achievement" // 達成部屋
        case luxury = "luxury"         // 豪華部屋
        
        var displayName: String {
            switch self {
            case .study: return NSLocalizedString("study_room", comment: "勉強部屋")
            case .relaxation: return NSLocalizedString("relaxation_room", comment: "くつろぎ部屋")
            case .nature: return NSLocalizedString("nature_room", comment: "自然部屋")
            case .technology: return NSLocalizedString("tech_room", comment: "テクノロジー部屋")
            case .achievement: return NSLocalizedString("achievement_room", comment: "達成部屋")
            case .luxury: return NSLocalizedString("luxury_room", comment: "豪華部屋")
            }
        }
        
        var bonusEffect: String {
            switch self {
            case .study: return NSLocalizedString("study_room_bonus", comment: "学習効率+10%")
            case .relaxation: return NSLocalizedString("relaxation_room_bonus", comment: "キャラクターの満足度+20%")
            case .nature: return NSLocalizedString("nature_room_bonus", comment: "自然の癒し効果")
            case .technology: return NSLocalizedString("tech_room_bonus", comment: "計算速度+5%")
            case .achievement: return NSLocalizedString("achievement_room_bonus", comment: "達成感+30%")
            case .luxury: return NSLocalizedString("luxury_room_bonus", comment: "すべての効果+5%")
            }
        }
    }
    
    /// ルームテーマ自動判定
    static func detectRoomTheme(room: CharacterRoom) -> RoomTheme? {
        let allItems = room.furniture + room.decorations
        var themeScores: [RoomTheme: Int] = [:]
        
        for item in allItems {
            if let itemData = RoomItemDatabase.allItems.first(where: { $0.id == item.id }) {
                let themes = getItemThemes(itemData)
                for theme in themes {
                    themeScores[theme, default: 0] += 1
                }
            }
        }
        
        // スコアが3以上のテーマのみ認定
        let validThemes = themeScores.filter { $0.value >= 3 }
        return validThemes.max(by: { $0.value < $1.value })?.key
    }
    
    private static func getItemThemes(_ item: RoomItemData) -> [RoomTheme] {
        switch item.id {
        case "furniture_desk", "furniture_bookshelf", "deco_poster_kuuku":
            return [.study]
        case "furniture_sofa", "furniture_tv", "deco_plushie":
            return [.relaxation]
        case "floor_tatami", "wall_forest", "deco_aquarium":
            return [.nature]
        case "furniture_piano", "floor_cloud", "wall_starry":
            return [.technology, .luxury]
        case let id where id.contains("trophy") || id.contains("special"):
            return [.achievement]
        case "furniture_piano", "deco_aquarium", "special_rainbow_fountain":
            return [.luxury]
        default:
            return []
        }
    }
}
```

この詳細仕様書により、キャラクター進化＆ルームカスタマイズシステムの実装に必要な全てのロジックが定義されました。