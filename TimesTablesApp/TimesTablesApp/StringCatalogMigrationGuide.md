# String Catalog分割移行ガイド

## 分割結果

元の`Localizable.xcstrings`ファイルを以下の4つのファイルに分割しました：

1. **Gamification.xcstrings** - ゲーミフィケーション関連（レベル、バッジ、デイリーチャレンジ）
2. **Questions.xcstrings** - 問題・解答関連
3. **UI.xcstrings** - UI操作・メッセージ関連
4. **Localizable.xcstrings** - 自動抽出される文字列・特殊文字

## キー移行マッピング

### Gamification.xcstrings に移行されたキー

| キー | 使用箇所 |
|------|----------|
| badge_* | Badge.swift, BadgeSystemViewState.swift |
| daily_challenge_* | DailyChallengeView.swift |
| level_* | LevelSystemViewState.swift, LevelDisplayView.swift |
| がんばってる | MasteryProgress.swift, ProgressVisualizationViewState.swift |
| がんばってる！ | ProgressVisualizationViewState.swift |
| マスター | MasteryProgress.swift, ProgressVisualizationViewState.swift |
| マスター✨ | ProgressVisualizationViewState.swift |
| もうすこし | MasteryProgress.swift, ProgressVisualizationViewState.swift |
| もうすこし！ | ProgressVisualizationViewState.swift |
| れんしゅうちゅう | MasteryProgress.swift, ProgressVisualizationViewState.swift |
| れんぞく %lldにち | ProgressVisualizationViewState.swift |

### Questions.xcstrings に移行されたキー

| キー | 使用箇所 |
|------|----------|
| correct_basic_points | MultiplicationViewState.swift |
| correct_bonus_points | MultiplicationViewState.swift |
| 不正解！正解は %lld です。もう一度チャレンジしてね。 | MultiplicationViewState.swift |
| 時間切れ！正解は %lld です。 | MultiplicationViewState.swift |
| おめでとう！%lldの だんを すべて クリアしました！ | MultiplicationViewState.swift |
| あなたのにがてな もんだい: | MultiplicationView.swift |
| まちがえた かいすう: %lld | MultiplicationView.swift |
| だんじゅんばん もんだい | MultiplicationView.swift |
| だんで もんだい | MultiplicationView.swift |
| むしくい もんだい | MultiplicationView.swift |
| ランダム もんだい | MultiplicationView.swift |
| せいかいりつ | MultiplicationMasterMapView.swift |
| といた もんだい | MultiplicationMasterMapView.swift |
| 正解率: %lld%% | StatsView.swift |
| その他問題関連文字列 | 各ViewとViewState |

### UI.xcstrings に移行されたキー

| キー | 使用箇所 |
|------|----------|
| ボタンをおして もんだいをやろう！ | MultiplicationView.swift |
| だんを えらぶ | MultiplicationView.swift |
| だんを えらんでね | MultiplicationView.swift |
| チャレンジOFF / チャレンジON | MultiplicationView.swift |
| 効果音 OFF / 効果音 ON | MultiplicationView.swift |
| 九九ティブ | MultiplicationView.swift |
| 九九マスターマップ | MultiplicationMasterMapView.swift |
| ポイント: %lld | MultiplicationView.swift |
| ポイントりれき | PointHistoryView.swift |
| とじる | 各View |
| やめる | QuestionSolvingView.swift |
| キャンセル | 各View |
| 確認 | 各View |
| PINコード関連 | ParentAccessView.swift |
| メッセージ関連 | CommunicationViewState.swift |
| 統計・グラフ関連 | StatsView.swift |
| バッジ | MultiplicationView.swift |
| その他UI要素 | 各View |

### Localizable.xcstrings に残されたキー

自動抽出される文字列、特殊文字、stale状態のキーを残しました：

- 特殊文字: `?`, `×`, `=`, `□`
- 数値フォーマット: `%lld`, `%lld × %lld`, `%lld × %lld = ?`, など
- 古いキー（extractionState: "stale"）
- 直接文字列として使用される項目

## コード更新方法

### 1. NSLocalizedString の更新

既存のコードでは以下のような記述があります：

```swift
// 更新前
Text(NSLocalizedString("daily_challenge_title", comment: "きょうのチャレンジ"))

// 更新後
Text(NSLocalizedString("daily_challenge_title", tableName: "Gamification", comment: "きょうのチャレンジ"))
```

### 2. String(localized:) の更新

```swift
// 更新前
String(localized: "level_title_beginner")

// 更新後
String(localized: "level_title_beginner", table: "Gamification")
```

### 3. 直接文字列使用の更新

```swift
// 更新前
Text("バッジ")

// 更新後
Text("バッジ", tableName: "UI")
```

## 必要な更新箇所

### 高優先度（レベル・バッジ関連）

1. **LevelSystemTests.swift**
   - 全てのNSLocalizedStringにtableName: "Gamification"を追加

2. **MasteryProgress.swift**
   - 全てのNSLocalizedStringにtableName: "Gamification"を追加

3. **DailyChallengeView.swift**
   - 全てのNSLocalizedStringにtableName: "Gamification"を追加

4. **LevelDisplayView.swift**
   - 全てのNSLocalizedStringにtableName: "Gamification"を追加

5. **ProgressVisualizationViewState.swift**
   - 全てのNSLocalizedStringにtableName: "Gamification"を追加

### 中優先度（問題・解答関連）

1. **MultiplicationViewState.swift**
   - correct_basic_points, correct_bonus_points → tableName: "Questions"
   - 不正解・時間切れメッセージ → tableName: "Questions"

2. **MultiplicationMasterMapView.swift**
   - せいかいりつ, といた もんだい → tableName: "Questions"

### 低優先度（UI関連）

1. **MultiplicationView.swift**
   - ボタンテキスト → tableName: "UI"
   - バッジ関連 → tableName: "UI"

2. **CommunicationViewState.swift**
   - メッセージテンプレート → tableName: "UI"

## 自動化スクリプト例

```bash
# 一括置換スクリプト例
find TimesTablesApp -name "*.swift" -type f -exec sed -i '' 's/NSLocalizedString("level_/NSLocalizedString("level_/g; s/comment: /tableName: "Gamification", comment: /g' {} \;
```

## 注意事項

1. **ビルドテスト**: 各ファイル更新後、必ずビルドテストを実行
2. **実機テスト**: 各言語でローカライズが正しく動作するか確認
3. **段階的移行**: 一度に全てを更新せず、機能単位で段階的に移行
4. **バックアップ**: 更新前にコードのバックアップを取得

## 検証方法

```bash
# 移行漏れチェック
grep -r "NSLocalizedString.*level_" --include="*.swift" TimesTablesApp/
grep -r "NSLocalizedString.*badge_" --include="*.swift" TimesTablesApp/
grep -r "NSLocalizedString.*daily_challenge_" --include="*.swift" TimesTablesApp/
```

この移行により、String Catalogファイルの管理がより効率的になり、機能別の翻訳作業が容易になります。