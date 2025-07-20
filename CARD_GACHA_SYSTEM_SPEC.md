# カードガチャシステム 詳細仕様書

## 1. カードシステム基礎仕様

### 1.1 カードレアリティ定義

```swift
enum CardRarity: Int, CaseIterable {
    case normal = 1      // ノーマル
    case rare = 2        // レア
    case superRare = 3   // スーパーレア
    case legendary = 4   // レジェンダリー
    
    var displayName: String {
        switch self {
        case .normal: return NSLocalizedString("normal", comment: "ノーマル")
        case .rare: return NSLocalizedString("rare", comment: "レア")
        case .superRare: return NSLocalizedString("super_rare", comment: "スーパーレア")
        case .legendary: return NSLocalizedString("legendary", comment: "レジェンダリー")
        }
    }
    
    var color: Color {
        switch self {
        case .normal: return .gray
        case .rare: return .blue
        case .superRare: return .purple
        case .legendary: return .orange
        }
    }
    
    var glowEffect: Bool {
        return self.rawValue >= 3 // スーパーレア以上で光る
    }
    
    var starCount: Int {
        return rawValue
    }
}
```

### 1.2 カードタイプ定義

```swift
enum CardType: String, CaseIterable {
    case character = "character"     // キャラクターカード
    case item = "item"              // アイテムカード
    case background = "background"   // 背景カード
    case special = "special"        // 特別カード
    case limited = "limited"        // 限定カード
    
    var displayName: String {
        switch self {
        case .character: return NSLocalizedString("character_card", comment: "キャラクターカード")
        case .item: return NSLocalizedString("item_card", comment: "アイテムカード")
        case .background: return NSLocalizedString("background_card", comment: "背景カード")
        case .special: return NSLocalizedString("special_card", comment: "特別カード")
        case .limited: return NSLocalizedString("limited_card", comment: "限定カード")
        }
    }
}
```

### 1.3 全カードデータベース

```swift
class CardDatabase {
    
    static let allCards: [CardData] = generateAllCards()
    
    private static func generateAllCards() -> [CardData] {
        var cards: [CardData] = []
        
        // 各段のキャラクターカード（9種類 × 9段 = 81種類）
        for table in 1...9 {
            cards.append(contentsOf: generateTableCharacterCards(table: table))
        }
        
        // アイテムカード
        cards.append(contentsOf: generateItemCards())
        
        // 背景カード
        cards.append(contentsOf: generateBackgroundCards())
        
        // 特別カード
        cards.append(contentsOf: generateSpecialCards())
        
        // 限定カード
        cards.append(contentsOf: generateLimitedCards())
        
        return cards
    }
    
    /// 各段のキャラクターカード生成
    private static func generateTableCharacterCards(table: Int) -> [CardData] {
        return [
            // ノーマル（4種類）
            CardData(
                id: "char_\(table)_warrior",
                cardNumber: table * 100 + 1,
                name: NSLocalizedString("table_\(table)_warrior", comment: "\(table)の段のせんし"),
                description: NSLocalizedString("table_\(table)_warrior_desc", comment: "\(table)の段をまもる勇敢なせんしです"),
                multiplicationTable: table,
                rarity: .normal,
                cardType: .character,
                imageAssetName: "card_char_\(table)_warrior",
                isLimited: false,
                limitedUntil: nil,
                unlockCondition: .tableProgress(table: table, correctCount: 10)
            ),
            CardData(
                id: "char_\(table)_mage",
                cardNumber: table * 100 + 2,
                name: NSLocalizedString("table_\(table)_mage", comment: "\(table)の段のまほうつかい"),
                description: NSLocalizedString("table_\(table)_mage_desc", comment: "\(table)の段のまほうをつかえます"),
                multiplicationTable: table,
                rarity: .normal,
                cardType: .character,
                imageAssetName: "card_char_\(table)_mage",
                isLimited: false,
                limitedUntil: nil,
                unlockCondition: .tableProgress(table: table, correctCount: 25)
            ),
            CardData(
                id: "char_\(table)_ninja",
                cardNumber: table * 100 + 3,
                name: NSLocalizedString("table_\(table)_ninja", comment: "\(table)の段のにんじゃ"),
                description: NSLocalizedString("table_\(table)_ninja_desc", comment: "すばやく\(table)の段をとく忍者です"),
                multiplicationTable: table,
                rarity: .normal,
                cardType: .character,
                imageAssetName: "card_char_\(table)_ninja",
                isLimited: false,
                limitedUntil: nil,
                unlockCondition: .fastAnswer(table: table, under3seconds: 10)
            ),
            CardData(
                id: "char_\(table)_scholar",
                cardNumber: table * 100 + 4,
                name: NSLocalizedString("table_\(table)_scholar", comment: "\(table)の段のがくしゃ"),
                description: NSLocalizedString("table_\(table)_scholar_desc", comment: "\(table)の段にくわしいがくしゃです"),
                multiplicationTable: table,
                rarity: .normal,
                cardType: .character,
                imageAssetName: "card_char_\(table)_scholar",
                isLimited: false,
                limitedUntil: nil,
                unlockCondition: .tableProgress(table: table, correctCount: 50)
            ),
            
            // レア（3種類）
            CardData(
                id: "char_\(table)_knight",
                cardNumber: table * 100 + 5,
                name: NSLocalizedString("table_\(table)_knight", comment: "\(table)の段のナイト"),
                description: NSLocalizedString("table_\(table)_knight_desc", comment: "\(table)の段をまもる高貴なナイトです"),
                multiplicationTable: table,
                rarity: .rare,
                cardType: .character,
                imageAssetName: "card_char_\(table)_knight",
                isLimited: false,
                limitedUntil: nil,
                unlockCondition: .tableProgress(table: table, correctCount: 100)
            ),
            CardData(
                id: "char_\(table)_dragon",
                cardNumber: table * 100 + 6,
                name: NSLocalizedString("table_\(table)_dragon", comment: "\(table)の段のドラゴン"),
                description: NSLocalizedString("table_\(table)_dragon_desc", comment: "\(table)の段のちからをもつドラゴンです"),
                multiplicationTable: table,
                rarity: .rare,
                cardType: .character,
                imageAssetName: "card_char_\(table)_dragon",
                isLimited: false,
                limitedUntil: nil,
                unlockCondition: .consecutiveCorrect(table: table, count: 20)
            ),
            CardData(
                id: "char_\(table)_phoenix",
                cardNumber: table * 100 + 7,
                name: NSLocalizedString("table_\(table)_phoenix", comment: "\(table)の段のフェニックス"),
                description: NSLocalizedString("table_\(table)_phoenix_desc", comment: "\(table)の段のでんせつのとりです"),
                multiplicationTable: table,
                rarity: .rare,
                cardType: .character,
                imageAssetName: "card_char_\(table)_phoenix",
                isLimited: false,
                limitedUntil: nil,
                unlockCondition: .perfectStreak(table: table, days: 7)
            ),
            
            // スーパーレア（1種類）
            CardData(
                id: "char_\(table)_master",
                cardNumber: table * 100 + 8,
                name: NSLocalizedString("table_\(table)_master", comment: "\(table)の段のマスター"),
                description: NSLocalizedString("table_\(table)_master_desc", comment: "\(table)の段をかんぺきにマスターした者"),
                multiplicationTable: table,
                rarity: .superRare,
                cardType: .character,
                imageAssetName: "card_char_\(table)_master",
                isLimited: false,
                limitedUntil: nil,
                unlockCondition: .tableMastery(table: table)
            ),
            
            // レジェンダリー（1種類）
            CardData(
                id: "char_\(table)_legend",
                cardNumber: table * 100 + 9,
                name: NSLocalizedString("table_\(table)_legend", comment: "\(table)の段のでんせつ"),
                description: NSLocalizedString("table_\(table)_legend_desc", comment: "\(table)の段のでんせつてきなそんざい"),
                multiplicationTable: table,
                rarity: .legendary,
                cardType: .character,
                imageAssetName: "card_char_\(table)_legend",
                isLimited: false,
                limitedUntil: nil,
                unlockCondition: .tableLegendary(table: table, perfectCount: 100)
            )
        ]
    }
    
    /// アイテムカード生成
    private static func generateItemCards() -> [CardData] {
        return [
            CardData(
                id: "item_calculator",
                cardNumber: 1001,
                name: NSLocalizedString("magic_calculator", comment: "まほうのけいさんき"),
                description: NSLocalizedString("magic_calculator_desc", comment: "どんなけいさんもできるまほうのけいさんき"),
                multiplicationTable: 0,
                rarity: .rare,
                cardType: .item,
                imageAssetName: "card_item_calculator",
                isLimited: false,
                limitedUntil: nil,
                unlockCondition: .totalProblems(1000)
            ),
            CardData(
                id: "item_crown",
                cardNumber: 1002,
                name: NSLocalizedString("wisdom_crown", comment: "ちえのおうかん"),
                description: NSLocalizedString("wisdom_crown_desc", comment: "ちえをあたえるおうかん"),
                multiplicationTable: 0,
                rarity: .legendary,
                cardType: .item,
                imageAssetName: "card_item_crown",
                isLimited: false,
                limitedUntil: nil,
                unlockCondition: .allTablesMastery
            ),
            // ... 他のアイテムカード
        ]
    }
    
    /// 背景カード生成
    private static func generateBackgroundCards() -> [CardData] {
        return [
            CardData(
                id: "bg_castle",
                cardNumber: 2001,
                name: NSLocalizedString("math_castle", comment: "さんすうのしろ"),
                description: NSLocalizedString("math_castle_desc", comment: "さんすうのちからがやどるしろ"),
                multiplicationTable: 0,
                rarity: .superRare,
                cardType: .background,
                imageAssetName: "card_bg_castle",
                isLimited: false,
                limitedUntil: nil,
                unlockCondition: .level(30)
            ),
            // ... 他の背景カード
        ]
    }
    
    /// 特別カード生成
    private static func generateSpecialCards() -> [CardData] {
        return [
            CardData(
                id: "special_rainbow",
                cardNumber: 3001,
                name: NSLocalizedString("rainbow_card", comment: "にじのカード"),
                description: NSLocalizedString("rainbow_card_desc", comment: "すべてのねがいをかなえるにじのカード"),
                multiplicationTable: 0,
                rarity: .legendary,
                cardType: .special,
                imageAssetName: "card_special_rainbow",
                isLimited: false,
                limitedUntil: nil,
                unlockCondition: .perfectAllTables
            ),
            // ... 他の特別カード
        ]
    }
    
    /// 限定カード生成
    private static func generateLimitedCards() -> [CardData] {
        return [
            // 月間限定カード（毎月3種類）
            CardData(
                id: "limited_2025_01_newyear",
                cardNumber: 4001,
                name: NSLocalizedString("newyear_2025_card", comment: "2025年おしょうがつカード"),
                description: NSLocalizedString("newyear_2025_card_desc", comment: "2025年おしょうがつのとくべつなカード"),
                multiplicationTable: 0,
                rarity: .legendary,
                cardType: .limited,
                imageAssetName: "card_limited_2025_01_newyear",
                isLimited: true,
                limitedUntil: Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 31)),
                unlockCondition: .monthlyRanking(rank: 100, month: "2025-01")
            ),
            // ... 他の限定カード
        ]
    }
}

struct CardData: Identifiable, Codable {
    let id: String
    let cardNumber: Int          // 図鑑番号
    let name: String
    let description: String
    let multiplicationTable: Int // 0は全段共通
    let rarity: CardRarity
    let cardType: CardType
    let imageAssetName: String
    let isLimited: Bool
    let limitedUntil: Date?
    let unlockCondition: UnlockCondition
    
    enum UnlockCondition: Codable {
        case tableProgress(table: Int, correctCount: Int)
        case fastAnswer(table: Int, under3seconds: Int)
        case consecutiveCorrect(table: Int, count: Int)
        case perfectStreak(table: Int, days: Int)
        case tableMastery(table: Int)
        case tableLegendary(table: Int, perfectCount: Int)
        case totalProblems(Int)
        case allTablesMastery
        case perfectAllTables
        case level(Int)
        case monthlyRanking(rank: Int, month: String)
        case gacha    // ガチャでのみ入手可能
    }
}
```

## 2. ガチャシステム詳細仕様

### 2.1 ガチャタイプ定義

```swift
enum GachaType: String, CaseIterable {
    case normal = "normal"           // 通常ガチャ
    case premium = "premium"         // プレミアムガチャ
    case tenPull = "ten_pull"       // 10連ガチャ
    case limited = "limited"        // 限定ガチャ
    case free = "free"              // 無料ガチャ
    
    var displayName: String {
        switch self {
        case .normal: return NSLocalizedString("normal_gacha", comment: "つうじょうガチャ")
        case .premium: return NSLocalizedString("premium_gacha", comment: "プレミアムガチャ")
        case .tenPull: return NSLocalizedString("ten_pull_gacha", comment: "10れんガチャ")
        case .limited: return NSLocalizedString("limited_gacha", comment: "げんていガチャ")
        case .free: return NSLocalizedString("free_gacha", comment: "むりょうガチャ")
        }
    }
    
    var cost: Int {
        switch self {
        case .normal: return 10
        case .premium: return 30
        case .tenPull: return 90  // 10ポイント割引
        case .limited: return 50
        case .free: return 0
        }
    }
    
    var pullCount: Int {
        switch self {
        case .normal, .premium, .limited, .free: return 1
        case .tenPull: return 10
        }
    }
}
```

### 2.2 ガチャ確率システム

```swift
class GachaProbabilitySystem {
    
    /// 基本確率テーブル
    static let baseProbabilities: [GachaType: [CardRarity: Double]] = [
        .normal: [
            .normal: 0.85,        // 85%
            .rare: 0.12,          // 12%
            .superRare: 0.03,     // 3%
            .legendary: 0.0       // 0% (通常ガチャでは出現しない)
        ],
        .premium: [
            .normal: 0.60,        // 60%
            .rare: 0.30,          // 30%
            .superRare: 0.09,     // 9%
            .legendary: 0.01      // 1%
        ],
        .limited: [
            .normal: 0.40,        // 40%
            .rare: 0.35,          // 35%
            .superRare: 0.20,     // 20%
            .legendary: 0.05      // 5%
        ],
        .free: [
            .normal: 0.95,        // 95%
            .rare: 0.05,          // 5%
            .superRare: 0.0,      // 0%
            .legendary: 0.0       // 0%
        ]
    ]
    
    /// ガチャ実行
    static func executeGacha(
        type: GachaType,
        userCollection: GachaCollection
    ) -> GachaResult {
        
        var pulledCards: [CollectionCard] = []
        var isGuaranteedRare = false
        
        for pullIndex in 0..<type.pullCount {
            // 10連ガチャの最後は高レア確定
            if type == .tenPull && pullIndex == 9 {
                isGuaranteedRare = true
            }
            
            let card = pullSingleCard(
                type: type,
                isGuaranteed: isGuaranteedRare,
                userCollection: userCollection
            )
            
            pulledCards.append(card)
        }
        
        // 天井システムチェック
        let pityResult = checkPitySystem(
            userCollection: userCollection,
            pulledCards: pulledCards
        )
        
        return GachaResult(
            pulledCards: pulledCards,
            pityTriggered: pityResult.triggered,
            pityCard: pityResult.card,
            newCards: filterNewCards(pulledCards, userCollection: userCollection),
            duplicateCards: filterDuplicateCards(pulledCards, userCollection: userCollection)
        )
    }
    
    /// 単発ガチャ実行
    private static func pullSingleCard(
        type: GachaType,
        isGuaranteed: Bool,
        userCollection: GachaCollection
    ) -> CollectionCard {
        
        let rarity: CardRarity
        
        if isGuaranteed {
            // 高レア確定の場合
            rarity = drawGuaranteedRareCard()
        } else {
            // 通常の確率抽選
            rarity = drawCardRarity(type: type)
        }
        
        // レアリティに基づいてカード選択
        let availableCards = getAvailableCards(
            rarity: rarity,
            type: type,
            userCollection: userCollection
        )
        
        guard let selectedCard = availableCards.randomElement() else {
            // フォールバック: ノーマルカードを返す
            return createCollectionCard(from: CardDatabase.allCards.first!)
        }
        
        return createCollectionCard(from: selectedCard)
    }
    
    /// レアリティ抽選
    private static func drawCardRarity(type: GachaType) -> CardRarity {
        let probabilities = baseProbabilities[type]!
        let random = Double.random(in: 0...1)
        var cumulative = 0.0
        
        for (rarity, probability) in probabilities {
            cumulative += probability
            if random <= cumulative {
                return rarity
            }
        }
        
        return .normal // フォールバック
    }
    
    /// 高レア確定抽選
    private static func drawGuaranteedRareCard() -> CardRarity {
        let random = Double.random(in: 0...1)
        
        if random <= 0.70 {      // 70%
            return .rare
        } else if random <= 0.95 { // 25%
            return .superRare
        } else {                 // 5%
            return .legendary
        }
    }
    
    /// 利用可能カード取得
    private static func getAvailableCards(
        rarity: CardRarity,
        type: GachaType,
        userCollection: GachaCollection
    ) -> [CardData] {
        
        var availableCards = CardDatabase.allCards.filter { card in
            card.rarity == rarity && isCardAvailable(card: card, type: type)
        }
        
        // 限定ガチャの場合は限定カードのみ
        if type == .limited {
            availableCards = availableCards.filter { $0.isLimited }
        } else {
            availableCards = availableCards.filter { !$0.isLimited }
        }
        
        return availableCards
    }
    
    /// カード入手可能性チェック
    private static func isCardAvailable(card: CardData, type: GachaType) -> Bool {
        // 期間限定カードの有効期限チェック
        if card.isLimited {
            if let limitedUntil = card.limitedUntil {
                return Date() <= limitedUntil
            }
        }
        
        // ガチャ条件チェック
        switch card.unlockCondition {
        case .gacha:
            return true // ガチャでのみ入手可能
        default:
            return false // 条件達成でのみ入手可能
        }
    }
    
    /// コレクションカード作成
    private static func createCollectionCard(from cardData: CardData) -> CollectionCard {
        return CollectionCard(
            id: UUID(),
            cardData: cardData,
            obtainedDate: Date(),
            obtainedCount: 1,
            obtainedMethod: .gacha
        )
    }
}

struct GachaResult {
    let pulledCards: [CollectionCard]
    let pityTriggered: Bool
    let pityCard: CollectionCard?
    let newCards: [CollectionCard]
    let duplicateCards: [CollectionCard]
    
    var totalCards: [CollectionCard] {
        var all = pulledCards
        if let pityCard = pityCard {
            all.append(pityCard)
        }
        return all
    }
}
```

### 2.3 天井システム

```swift
class PitySystem {
    
    /// 天井カウンター定義
    static let maxPityCount = 100    // 100回で天井
    static let monthlyReset = true   // 月次リセット
    
    /// 天井システムチェック
    static func checkPitySystem(
        userCollection: GachaCollection,
        pulledCards: [CollectionCard]
    ) -> PityResult {
        
        let currentCount = userCollection.legendaryPityCounter
        let newCount = currentCount + pulledCards.count
        
        // レジェンダリーが出た場合はカウンターリセット
        let hasLegendary = pulledCards.contains { $0.cardData.rarity == .legendary }
        if hasLegendary {
            return PityResult(triggered: false, card: nil, newCounter: 0)
        }
        
        // 天井到達チェック
        if newCount >= maxPityCount {
            let pityCard = generatePityCard()
            return PityResult(triggered: true, card: pityCard, newCounter: 0)
        }
        
        return PityResult(triggered: false, card: nil, newCounter: newCount)
    }
    
    /// 天井カード生成
    private static func generatePityCard() -> CollectionCard {
        let legendaryCards = CardDatabase.allCards.filter { 
            $0.rarity == .legendary && !$0.isLimited 
        }
        
        guard let randomLegendary = legendaryCards.randomElement() else {
            fatalError("No legendary cards available for pity system")
        }
        
        return CollectionCard(
            id: UUID(),
            cardData: randomLegendary,
            obtainedDate: Date(),
            obtainedCount: 1,
            obtainedMethod: .pity
        )
    }
    
    /// 月次リセット処理
    static func resetMonthlyPity() {
        // 実装: 全ユーザーの天井カウンターを0にリセット
    }
}

struct PityResult {
    let triggered: Bool
    let card: CollectionCard?
    let newCounter: Int
}
```

## 3. カードコレクション管理システム

### 3.1 コレクション機能

```swift
class CardCollectionManager {
    
    /// カード図鑑データ取得
    static func getCollectionBook() -> CollectionBook {
        let allCards = CardDatabase.allCards
        let ownedCards = DataStore.shared.getOwnedCards()
        
        var bookEntries: [CollectionBookEntry] = []
        
        for card in allCards {
            let owned = ownedCards.first { $0.cardData.id == card.id }
            let entry = CollectionBookEntry(
                cardData: card,
                isOwned: owned != nil,
                obtainedCount: owned?.obtainedCount ?? 0,
                firstObtainedDate: owned?.obtainedDate
            )
            bookEntries.append(entry)
        }
        
        return CollectionBook(entries: bookEntries)
    }
    
    /// 段別コレクション進捗
    static func getTableCollectionProgress(table: Int) -> TableCollectionProgress {
        let tableCards = CardDatabase.allCards.filter { 
            $0.multiplicationTable == table 
        }
        let ownedTableCards = DataStore.shared.getOwnedCards().filter { 
            $0.cardData.multiplicationTable == table 
        }
        
        let totalCards = tableCards.count
        let ownedCards = ownedTableCards.count
        let completionRate = Double(ownedCards) / Double(totalCards)
        
        return TableCollectionProgress(
            table: table,
            totalCards: totalCards,
            ownedCards: ownedCards,
            completionRate: completionRate,
            isCompleted: ownedCards == totalCards
        )
    }
    
    /// レアリティ別コレクション進捗
    static func getRarityCollectionProgress() -> [RarityCollectionProgress] {
        var progress: [RarityCollectionProgress] = []
        
        for rarity in CardRarity.allCases {
            let rarityCards = CardDatabase.allCards.filter { $0.rarity == rarity }
            let ownedRarityCards = DataStore.shared.getOwnedCards().filter { 
                $0.cardData.rarity == rarity 
            }
            
            progress.append(RarityCollectionProgress(
                rarity: rarity,
                totalCards: rarityCards.count,
                ownedCards: ownedRarityCards.count,
                completionRate: Double(ownedRarityCards.count) / Double(rarityCards.count)
            ))
        }
        
        return progress
    }
    
    /// コンプリート報酬チェック
    static func checkCompletionRewards() -> [CompletionReward] {
        var rewards: [CompletionReward] = []
        
        // 段別コンプリート報酬
        for table in 1...9 {
            let progress = getTableCollectionProgress(table: table)
            if progress.isCompleted && !hasReceivedReward(type: .tableCompletion(table)) {
                rewards.append(CompletionReward(
                    type: .tableCompletion(table),
                    points: 50,
                    specialCard: nil
                ))
            }
        }
        
        // レアリティ別コンプリート報酬
        for rarity in CardRarity.allCases {
            let progress = getRarityCollectionProgress().first { $0.rarity == rarity }!
            if progress.completionRate >= 1.0 && !hasReceivedReward(type: .rarityCompletion(rarity)) {
                let rewardPoints = rarity.rawValue * 100
                rewards.append(CompletionReward(
                    type: .rarityCompletion(rarity),
                    points: rewardPoints,
                    specialCard: nil
                ))
            }
        }
        
        // 全カードコンプリート報酬
        let totalProgress = getTotalCollectionProgress()
        if totalProgress.completionRate >= 1.0 && !hasReceivedReward(type: .allCompletion) {
            let ultimateCard = generateUltimateCard()
            rewards.append(CompletionReward(
                type: .allCompletion,
                points: 1000,
                specialCard: ultimateCard
            ))
        }
        
        return rewards
    }
    
    private static func hasReceivedReward(type: CompletionRewardType) -> Bool {
        // 実装: 報酬受取履歴をチェック
        return false
    }
    
    private static func generateUltimateCard() -> CollectionCard {
        // 実装: 究極のカードを生成
        let ultimateCardData = CardData(
            id: "ultimate_master",
            cardNumber: 9999,
            name: NSLocalizedString("ultimate_master", comment: "きゅうきょくのマスター"),
            description: NSLocalizedString("ultimate_master_desc", comment: "すべてのカードをあつめたしょうにん"),
            multiplicationTable: 0,
            rarity: .legendary,
            cardType: .special,
            imageAssetName: "card_ultimate_master",
            isLimited: false,
            limitedUntil: nil,
            unlockCondition: .gacha
        )
        
        return CollectionCard(
            id: UUID(),
            cardData: ultimateCardData,
            obtainedDate: Date(),
            obtainedCount: 1,
            obtainedMethod: .reward
        )
    }
    
    /// 総合コレクション進捗
    static func getTotalCollectionProgress() -> CollectionProgress {
        let totalCards = CardDatabase.allCards.count
        let ownedCards = DataStore.shared.getOwnedCards().count
        
        return CollectionProgress(
            totalCards: totalCards,
            ownedCards: ownedCards,
            completionRate: Double(ownedCards) / Double(totalCards)
        )
    }
}

struct CollectionBook {
    let entries: [CollectionBookEntry]
    
    var totalCards: Int { entries.count }
    var ownedCards: Int { entries.filter { $0.isOwned }.count }
    var completionRate: Double { Double(ownedCards) / Double(totalCards) }
}

struct CollectionBookEntry {
    let cardData: CardData
    let isOwned: Bool
    let obtainedCount: Int
    let firstObtainedDate: Date?
}

struct TableCollectionProgress {
    let table: Int
    let totalCards: Int
    let ownedCards: Int
    let completionRate: Double
    let isCompleted: Bool
}

struct RarityCollectionProgress {
    let rarity: CardRarity
    let totalCards: Int
    let ownedCards: Int
    let completionRate: Double
}

struct CollectionProgress {
    let totalCards: Int
    let ownedCards: Int
    let completionRate: Double
}

struct CompletionReward {
    let type: CompletionRewardType
    let points: Int
    let specialCard: CollectionCard?
}

enum CompletionRewardType {
    case tableCompletion(Int)
    case rarityCompletion(CardRarity)
    case allCompletion
}
```

## 4. ガチャUI演出システム

### 4.1 ガチャ演出シーケンス

```swift
class GachaAnimationController {
    
    /// ガチャ演出実行
    static func executeGachaAnimation(
        result: GachaResult,
        completion: @escaping () -> Void
    ) {
        
        // 1. ガチャ開始演出
        playOpeningAnimation {
            
            // 2. カード出現演出
            self.revealCards(result.totalCards) {
                
                // 3. 新カード強調演出
                if !result.newCards.isEmpty {
                    self.highlightNewCards(result.newCards) {
                        
                        // 4. レア演出
                        self.playRareCardEffects(result.totalCards) {
                            
                            // 5. 完了
                            completion()
                        }
                    }
                } else {
                    // 新カードがない場合
                    self.playRareCardEffects(result.totalCards) {
                        completion()
                    }
                }
            }
        }
    }
    
    /// 開始演出
    private static func playOpeningAnimation(completion: @escaping () -> Void) {
        // ガチャボックスが光る演出
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion()
        }
    }
    
    /// カード出現演出
    private static func revealCards(
        _ cards: [CollectionCard],
        completion: @escaping () -> Void
    ) {
        
        var delay: Double = 0
        
        for (index, card) in cards.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                
                // カードフリップアニメーション
                self.flipCard(card) {
                    // 最後のカードの演出完了後にコールバック
                    if index == cards.count - 1 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            completion()
                        }
                    }
                }
            }
            
            delay += 0.3 // 0.3秒間隔
        }
    }
    
    /// カードフリップアニメーション
    private static func flipCard(
        _ card: CollectionCard,
        completion: @escaping () -> Void
    ) {
        
        // レアリティに応じたエフェクト
        switch card.cardData.rarity {
        case .normal:
            playNormalCardFlip(completion: completion)
        case .rare:
            playRareCardFlip(completion: completion)
        case .superRare:
            playSuperRareCardFlip(completion: completion)
        case .legendary:
            playLegendaryCardFlip(completion: completion)
        }
    }
    
    /// ノーマルカードフリップ
    private static func playNormalCardFlip(completion: @escaping () -> Void) {
        // シンプルなフリップアニメーション
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion()
        }
    }
    
    /// レアカードフリップ
    private static func playRareCardFlip(completion: @escaping () -> Void) {
        // 青い光エフェクト付きフリップ
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            completion()
        }
    }
    
    /// スーパーレアカードフリップ
    private static func playSuperRareCardFlip(completion: @escaping () -> Void) {
        // 紫の光エフェクト + パーティクル
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            completion()
        }
    }
    
    /// レジェンダリーカードフリップ
    private static func playLegendaryCardFlip(completion: @escaping () -> Void) {
        // 虹色エフェクト + 特別音楽 + 画面震動
        playRainbowEffect()
        playLegendaryMusic()
        triggerHapticFeedback()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            completion()
        }
    }
    
    /// 新カード強調演出
    private static func highlightNewCards(
        _ newCards: [CollectionCard],
        completion: @escaping () -> Void
    ) {
        
        // "NEW!" バッジ表示
        for card in newCards {
            showNewCardBadge(for: card)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion()
        }
    }
    
    /// レアカード特別エフェクト
    private static func playRareCardEffects(
        _ cards: [CollectionCard],
        completion: @escaping () -> Void
    ) {
        
        let hasLegendary = cards.contains { $0.cardData.rarity == .legendary }
        let hasSuperRare = cards.contains { $0.cardData.rarity == .superRare }
        
        if hasLegendary {
            playLegendaryConfetti {
                completion()
            }
        } else if hasSuperRare {
            playSuperRareSparkles {
                completion()
            }
        } else {
            completion()
        }
    }
    
    // MARK: - エフェクト実装関数
    
    private static func playRainbowEffect() {
        // 虹色エフェクト実装
    }
    
    private static func playLegendaryMusic() {
        // 特別音楽再生
    }
    
    private static func triggerHapticFeedback() {
        // バイブレーション
    }
    
    private static func showNewCardBadge(for card: CollectionCard) {
        // NEWバッジ表示
    }
    
    private static func playLegendaryConfetti(completion: @escaping () -> Void) {
        // 紙吹雪エフェクト
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            completion()
        }
    }
    
    private static func playSuperRareSparkles(completion: @escaping () -> Void) {
        // キラキラエフェクト
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion()
        }
    }
}
```

### 4.2 カード表示システム

```swift
class CardDisplaySystem {
    
    /// カード詳細表示
    static func displayCardDetail(_ card: CollectionCard) -> CardDetailView {
        return CardDetailView(
            card: card,
            showObtainedInfo: true,
            showStats: true,
            allowFavorite: true
        )
    }
    
    /// カード一覧表示設定
    static func getCardListConfiguration(
        filterBy: CardFilter = .all,
        sortBy: CardSortOption = .cardNumber
    ) -> CardListConfiguration {
        
        return CardListConfiguration(
            filter: filterBy,
            sort: sortBy,
            showUnowned: true,
            showObtainedCount: true,
            gridColumns: 3
        )
    }
}

enum CardFilter {
    case all
    case owned
    case unowned
    case rarity(CardRarity)
    case table(Int)
    case cardType(CardType)
    case limited
    case new
}

enum CardSortOption {
    case cardNumber
    case obtainedDate
    case rarity
    case name
    case table
}

struct CardListConfiguration {
    let filter: CardFilter
    let sort: CardSortOption
    let showUnowned: Bool
    let showObtainedCount: Bool
    let gridColumns: Int
}
```

この詳細仕様書により、カードガチャシステムの完全な実装が可能になります。確率システム、天井システム、コレクション機能、演出システムまで網羅されています。