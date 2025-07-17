# Task: ゲーミフィケーション要素 - レベルシステム実装

## 目的・背景
現在の九九アプリは基本的な学習機能と統計機能を備えているが、長期的な学習継続モチベーションの維持が課題となっている。レベルシステムを導入することで、問題を解くたびに経験値を獲得し、レベルアップする楽しさを提供し、学習の継続意欲を向上させる。

## 成功基準
- [ ] 総解答問題数に基づくレベルシステム（Lv.1〜50）の実装
- [ ] レベルアップ時の視覚的フィードバック（アニメーション・サウンド）
- [ ] レベルに応じた称号システムの実装
- [ ] ホーム画面への現在レベル・進捗表示
- [ ] 既存のSVVSパターンに準拠した実装
- [ ] SwiftDataモデルによるレベルデータの永続化
- [ ] swift-testingフレームワークでのテスト実装

## 実装計画
### Phase 1: 調査・設計
- [ ] 既存のDataStore、UserPointsモデルの調査
- [ ] レベル計算ロジックの設計（必要経験値曲線の定義）
- [ ] UI/UXデザインの検討（レベル表示位置、アニメーション仕様）
- [ ] SwiftDataモデル設計（UserLevel, LevelProgress）

### Phase 2: 実装
- [ ] UserLevelモデルの作成（SwiftData）
- [ ] LevelProgressモデルの作成（レベル進捗追跡）
- [ ] LevelSystemViewStateの実装（@MainActor）
- [ ] レベル計算ロジックの実装（経験値獲得・レベルアップ判定）
- [ ] レベル表示UIコンポーネントの作成
- [ ] レベルアップアニメーション・サウンドの実装
- [ ] 称号システムの実装（「九九みならい」→「九九せんし」→「九九マスター」等）
- [ ] ホーム画面（ContentView）へのレベル表示統合
- [ ] DataStoreへのレベル管理機能追加

### Phase 3: 検証
- [ ] ViewStateのテスト作成（@MainActor）
- [ ] レベル計算ロジックのユニットテスト
- [ ] レベルアップ時の動作確認
- [ ] パフォーマンステスト（大量の問題解答時）
- [ ] 既存機能との統合テスト

## 注意事項
- 既存のポイントシステムとの連携を考慮（1問正解=1経験値=1ポイント）
- 小学2年生向けの分かりやすい日本語表記
- ローカライゼーション対応（日英両対応）
- レベルアップ時の演出は学習の妨げにならない程度に
- 既存ユーザーのデータ移行を考慮（初回起動時の経験値計算）

## 技術要素
- **使用技術**: SwiftUI, SwiftData, AVFoundation（サウンド）
- **対象ファイル**: 
  - Models/UserLevel.swift（新規）
  - Models/LevelProgress.swift（新規）
  - ViewStates/LevelSystemViewState.swift（新規）
  - Views/Components/LevelDisplayView.swift（新規）
  - Views/Components/LevelUpAnimationView.swift（新規）
  - Views/ContentView.swift（更新）
  - DataStore.swift（更新）
- **作業範囲**: フロントエンド中心（データモデル〜UI実装まで）

## 進捗メモ
[作業進捗を随時更新]

## 保存先: .claude/workspace/task.md