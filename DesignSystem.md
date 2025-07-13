# 九九学習アプリ デザインシステム

## 1. デザイン原則

### 基本理念
- **楽しく学べる**: 子どもが継続的に使いたくなる、親しみやすいデザイン
- **分かりやすい**: 直感的で迷わない操作性
- **安心・安全**: 目に優しく、長時間使用しても疲れにくい配色
- **達成感**: 正解時の喜びや成長を視覚的に表現

## 2. カラーシステム

### プライマリカラー
```swift
// メインカラー
let primary = Color(hex: "007AFF")        // iOS標準のブルー
let primaryLight = Color(hex: "5AC8FA")   // 明るいブルー（アクセント）
let primaryDark = Color(hex: "005493")    // 濃いブルー（強調）

// セカンダリカラー
let secondary = Color(hex: "34C759")      // 成功・正解（グリーン）
let secondaryLight = Color(hex: "7DCE8A") // 明るいグリーン
let error = Color(hex: "FF3B30")         // エラー・不正解（レッド）
let errorLight = Color(hex: "FF6B64")     // 明るいレッド
```

### ニュートラルカラー
```swift
// グレースケール
let gray100 = Color(hex: "F2F2F7")  // 背景
let gray200 = Color(hex: "E5E5EA")  // カード背景
let gray300 = Color(hex: "D1D1D6")  // 無効状態
let gray400 = Color(hex: "C7C7CC")  // プレースホルダー
let gray500 = Color(hex: "8E8E93")  // セカンダリテキスト
let gray600 = Color(hex: "636366")  // ラベル
let gray700 = Color(hex: "48484A")  // プライマリテキスト
let gray800 = Color(hex: "3A3A3C")  // 見出し
let gray900 = Color(hex: "1C1C1E")  // 最重要テキスト
```

### 特殊カラー
```swift
// ゲーミフィケーション
let gold = Color(hex: "FFD700")      // ゴールド（特別な達成）
let silver = Color(hex: "C0C0C0")    // シルバー（準達成）
let bronze = Color(hex: "CD7F32")    // ブロンズ（達成）

// ステータス
let warning = Color(hex: "FF9500")   // 警告・注意
let info = Color(hex: "5856D6")      // 情報・ヒント
```

## 3. タイポグラフィ

### フォントファミリー
```swift
// システムフォント（SF Pro）を基本とする
let fontFamily = Font.system
```

### フォントサイズとウェイト
```swift
// 見出し
let largeTitle = Font.system(size: 34, weight: .bold)      // 大見出し
let title1 = Font.system(size: 28, weight: .bold)          // 見出し1
let title2 = Font.system(size: 22, weight: .semibold)      // 見出し2
let title3 = Font.system(size: 20, weight: .semibold)      // 見出し3

// 本文
let body = Font.system(size: 17, weight: .regular)         // 標準本文
let bodyBold = Font.system(size: 17, weight: .semibold)    // 強調本文
let callout = Font.system(size: 16, weight: .regular)      // 吹き出し
let subheadline = Font.system(size: 15, weight: .regular)  // サブ見出し
let footnote = Font.system(size: 13, weight: .regular)     // 注釈
let caption1 = Font.system(size: 12, weight: .regular)     // キャプション1
let caption2 = Font.system(size: 11, weight: .regular)     // キャプション2

// 特殊用途（九九の問題表示）
let questionLarge = Font.system(size: 48, weight: .bold)   // 問題文（大）
let questionMedium = Font.system(size: 36, weight: .bold)  // 問題文（中）
let answerButton = Font.system(size: 24, weight: .semibold) // 回答ボタン
```

### 行間とレタースペーシング
```swift
// 行高さ
let tightLineSpacing: CGFloat = 1.0    // タイト
let defaultLineSpacing: CGFloat = 1.2  // 標準
let looseLineSpacing: CGFloat = 1.5    // ゆったり

// 文字間隔
let tightKerning: CGFloat = -0.5       // タイト
let defaultKerning: CGFloat = 0        // 標準
let looseKerning: CGFloat = 0.5        // ゆったり
```

## 4. 余白・間隔システム

### 基本単位（8ptグリッド）
```swift
let spacing2: CGFloat = 2   // 極小
let spacing4: CGFloat = 4   // 最小
let spacing8: CGFloat = 8   // 小
let spacing12: CGFloat = 12 // やや小
let spacing16: CGFloat = 16 // 標準
let spacing20: CGFloat = 20 // やや大
let spacing24: CGFloat = 24 // 大
let spacing32: CGFloat = 32 // 特大
let spacing40: CGFloat = 40 // 超特大
let spacing48: CGFloat = 48 // 最大
```

### 使用ガイドライン
- **要素間の余白**: spacing8〜spacing16
- **セクション間の余白**: spacing24〜spacing32
- **画面端からの余白**: spacing16〜spacing20
- **ボタン内のパディング**: 
  - 水平: spacing16〜spacing24
  - 垂直: spacing12〜spacing16

## 5. 角丸（Corner Radius）

```swift
let radiusSmall: CGFloat = 4      // 小さい要素（タグ、バッジ）
let radiusMedium: CGFloat = 8     // 標準要素（ボタン、入力欄）
let radiusLarge: CGFloat = 12     // 大きい要素（カード）
let radiusXLarge: CGFloat = 16    // 特大要素（モーダル）
let radiusCircle: CGFloat = .infinity // 円形要素
```

### 使用ガイドライン
- **ボタン**: radiusMedium（8pt）
- **カード**: radiusLarge（12pt）
- **モーダル/シート**: radiusXLarge（16pt）
- **アバター/プロフィール画像**: radiusCircle
- **小さなタグ/バッジ**: radiusSmall（4pt）

## 6. 影の効果（Shadow）

```swift
// 影のレベル
struct ShadowStyle {
    let color: Color = Color.black
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    let opacity: Double
}

// 定義済みの影スタイル
let shadowNone = ShadowStyle(radius: 0, x: 0, y: 0, opacity: 0)
let shadowSmall = ShadowStyle(radius: 4, x: 0, y: 2, opacity: 0.1)
let shadowMedium = ShadowStyle(radius: 8, x: 0, y: 4, opacity: 0.15)
let shadowLarge = ShadowStyle(radius: 16, x: 0, y: 8, opacity: 0.2)
let shadowXLarge = ShadowStyle(radius: 24, x: 0, y: 12, opacity: 0.25)
```

### 使用ガイドライン
- **フローティングボタン**: shadowLarge
- **カード（デフォルト）**: shadowMedium
- **カード（ホバー/選択時）**: shadowLarge
- **モーダル/シート**: shadowXLarge
- **インライン要素**: shadowSmall または shadowNone

## 7. コンポーネント設計

### ボタン

#### プライマリボタン
```swift
struct PrimaryButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, spacing24)
            .padding(.vertical, spacing12)
            .background(Color.primary)
            .cornerRadius(radiusMedium)
            .shadow(color: shadowMedium.color.opacity(shadowMedium.opacity),
                   radius: shadowMedium.radius, x: shadowMedium.x, y: shadowMedium.y)
    }
}
```

#### セカンダリボタン
```swift
struct SecondaryButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.primary)
            .padding(.horizontal, spacing24)
            .padding(.vertical, spacing12)
            .background(Color.gray200)
            .cornerRadius(radiusMedium)
    }
}
```

#### 回答ボタン（九九専用）
```swift
struct AnswerButton: ViewModifier {
    let isSelected: Bool
    let isCorrect: Bool?
    
    func body(content: Content) -> some View {
        content
            .font(answerButton)
            .foregroundColor(foregroundColor)
            .frame(width: 80, height: 80)
            .background(backgroundColor)
            .cornerRadius(radiusLarge)
            .shadow(color: shadowMedium.color.opacity(shadowMedium.opacity),
                   radius: shadowMedium.radius, x: shadowMedium.x, y: shadowMedium.y)
            .scaleEffect(isSelected ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
    
    var foregroundColor: Color {
        if let isCorrect = isCorrect {
            return .white
        }
        return isSelected ? .white : .gray700
    }
    
    var backgroundColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .secondary : .error
        }
        return isSelected ? .primary : .gray200
    }
}
```

### カード
```swift
struct Card: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(spacing16)
            .background(Color.white)
            .cornerRadius(radiusLarge)
            .shadow(color: shadowMedium.color.opacity(shadowMedium.opacity),
                   radius: shadowMedium.radius, x: shadowMedium.x, y: shadowMedium.y)
    }
}
```

### 入力フィールド
```swift
struct InputField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body)
            .padding(.horizontal, spacing16)
            .padding(.vertical, spacing12)
            .background(Color.gray100)
            .cornerRadius(radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: radiusMedium)
                    .stroke(Color.gray300, lineWidth: 1)
            )
    }
}
```

### バッジ
```swift
struct Badge: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .font(.caption1)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, spacing8)
            .padding(.vertical, spacing4)
            .background(color)
            .cornerRadius(radiusSmall)
    }
}
```

### プログレスバー
```swift
struct ProgressBar: View {
    let progress: Double
    let height: CGFloat = 8
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.gray200)
                    .frame(height: height)
                
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.primary)
                    .frame(width: geometry.size.width * progress, height: height)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
            }
        }
        .frame(height: height)
    }
}
```

## 8. アニメーション

### 基本的なアニメーション設定
```swift
// スプリングアニメーション（推奨）
let springDefault = Animation.spring(response: 0.5, dampingFraction: 0.8)
let springBouncy = Animation.spring(response: 0.6, dampingFraction: 0.6)
let springSmooth = Animation.spring(response: 0.4, dampingFraction: 0.9)

// イージングアニメーション
let easeInOut = Animation.easeInOut(duration: 0.3)
let easeOut = Animation.easeOut(duration: 0.25)

// 遅延アニメーション
let delayedSpring = Animation.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)
```

### 使用ガイドライン
- **ボタンタップ**: springBouncy（弾むような動き）
- **画面遷移**: springDefault
- **プログレス更新**: springSmooth
- **フェードイン/アウト**: easeInOut
- **成功時のアニメーション**: springBouncy + スケール効果

## 9. アクセシビリティ

### カラーコントラスト
- 通常テキスト: 最低4.5:1のコントラスト比
- 大きなテキスト（18pt以上）: 最低3:1のコントラスト比
- 重要なUI要素: 最低3:1のコントラスト比

### VoiceOver対応
```swift
// ボタンの例
Button(action: {}) {
    Text("答える")
}
.accessibilityLabel("答えを送信")
.accessibilityHint("タップして回答を送信します")
```

### ダイナミックタイプ対応
- すべてのテキストはダイナミックタイプに対応
- 最小フォントサイズと最大フォントサイズを設定

## 10. ダークモード対応

### カラー定義
```swift
// Asset Catalogでダークモード対応の色を定義
extension Color {
    static let background = Color("Background")     // Light: gray100, Dark: black
    static let cardBackground = Color("CardBG")     // Light: white, Dark: gray800
    static let primaryText = Color("PrimaryText")   // Light: gray900, Dark: white
    static let secondaryText = Color("SecondaryText") // Light: gray600, Dark: gray400
}
```

## 実装例

### 九九の問題カード
```swift
struct QuestionCard: View {
    let question: String
    let timeRemaining: Int
    
    var body: some View {
        VStack(spacing: spacing24) {
            // タイマー
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(timeColor)
                Text("\(timeRemaining)秒")
                    .font(.subheadline)
                    .foregroundColor(timeColor)
            }
            
            // 問題
            Text(question)
                .font(questionLarge)
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.center)
        }
        .padding(spacing32)
        .frame(maxWidth: .infinity)
        .modifier(Card())
    }
    
    var timeColor: Color {
        switch timeRemaining {
        case 0...3:
            return .error
        case 4...6:
            return .warning
        default:
            return .secondaryText
        }
    }
}
```

### 成功時のフィードバック
```swift
struct SuccessAnimation: View {
    @State private var scale = 0.5
    @State private var opacity = 0.0
    
    var body: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 80))
            .foregroundColor(.secondary)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(springBouncy) {
                    scale = 1.0
                    opacity = 1.0
                }
                
                withAnimation(easeOut.delay(0.8)) {
                    opacity = 0.0
                }
            }
    }
}
```

---

このデザインシステムは、子どもが楽しく九九を学べるように、親しみやすく、分かりやすく、そして達成感を感じられるデザインを目指しています。実装時は、このガイドラインに従いながら、必要に応じて調整を加えてください。