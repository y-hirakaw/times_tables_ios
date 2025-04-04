# このソースコードの説明

* このアプリはSwiftで書かれたiOSアプリです。
  * 九九ができるアプリになる予定です。

# 実装済みの機能

## 1. 九九チャレンジ機能（基本の学習部分）

* 1-1. 問題が出題される（ランダム）
* 1-2. ユーザーが回答できる
* 1-3. 正解・不正解を判定し、ポイントを加算
* 1-4. 間違えた問題の記録（「苦手」認定のため）
* 1-5. 苦手な問題が50%確率で出題されるチャンレンジモード
* 1-6. 正解・不正解時に音を鳴らす（画面上で音のON/OFFが出来る）
* 1-7. 1問を解く時間制限を設ける
  * 残り時間表示
  * 10秒経過すると不正解扱い
  * 解くまでにかかった時間の記録

実装箇所: Views/MultiplicationView.swift

## 2. ポイントシステム

* 2-1. 正解したらポイントGET
* 2-2. 苦手な問題のポイントUP（最初は固定でもOK）

実装箇所: Views/MultiplicationView.swift

## 3. 親の管理画面

* 3-1. 子どものポイントを確認できる
* 3-2. ポイントのリセット or 交換（指定ポイントの消費）

実装箇所: Views/ParentDashboardView/ParentDashboardView.swift

## 4. 学習統計画面

* 4-1. 得意・苦手の円グラフ
* 4-2. 苦手な問題一覧
* 4-3. 週単位での苦手問題推移の棒グラフ

実装箇所: Views/StatsView/StatsView.swift

# 今後実装予定の機能

* 問題出題をランダム以外にも実装する
  * 段指定のランダム出題
* 獲得ポイントを一覧で見れる（親管理画面とは別）
* ポイント獲得の調整
* 年齢入力(生年月日ではない)
  * 年齢別の統計情報と自分の統計比較
* ランクシステム
  * 得意問題の割合から◯◯マスターみたいな称号やバッチがもらえる
* データ引き継ぎ(機種変更対策)

# 要件

* コードを追加した場合はビルドしてコンパイルエラーが発生していないか確認し、エラーがある場合は解消してから再度ビルドして確かめてください。
* テストコードはswift-testingで書いてください。XCTestは極力書かないでください。
  * ViewStateのテストは必ず書いてください。
* 既存コードの修正、テストコードを追加・修正した場合はテストを実行してエラーが発生していないか確認し、エラーがある場合は解消してから再度ビルドして確かめてください。
  * ただし、現状テストコードの実行時Agentはコマンド実行完了を待てない場合があるので、一度実行して結果を取得できない場合はテストの手動実行を依頼してください。
* 意図の把握が難しい関数がある場合はSwiftDocを記載してください。可能なら意図がわかるように実装してください。
* このアプリのプライマリー言語は日本語ですが、英語も対応しています。日本語のテキストを追加した場合は英語対応も必要です。
  * ローカライズするファイルはLocalizable.xcstringsです。
  * 日本語で表示するテキストの漢字は小学二年生までの漢字を使ってください。それ以外はひらがなとカタカナと数字を使ってください。
  * ただし、編集に時間がかかるためLocalizable.xcstringsは指示があるまで編集対象にしないでください。

# このアプリで利用されているSVVSアーキテクチャについての説明
  
* SVVSでは、ViewのアクションがViewStateを通じてStoreに伝達されます。StoreはAPIやDBと通信し、シングルトンでデータを保持します。
* Storeのデータ変更はViewStateを介してViewに反映され、単方向データフローを実現します。

# テストコードについての補足

* ViewStateのテストコードはstructの定義の上に`@MainActor`が必要です。

# 動作確認について

* ビルドは以下のコマンドで行ってください。
```
xcodebuild -scheme TimesTablesApp \
  -configuration Debug \
  -project TimesTablesApp/TimesTablesApp.xcodeproj \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  -allowProvisioningUpdates build | xcbeautify
```
* テストの実行は以下のコマンドで行ってください。
```
xcodebuild -scheme TimesTablesApp \
  -configuration Debug \
  -workspace TimesTablesApp/TimesTablesApp.xcodeproj/project.xcworkspace \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  -destination-timeout 60 \
  -only-testing:TimesTablesAppTests test \
  -verbose | xcbeautify
```

# PR作成について

* 以下のフォーマットで対応内容をPRに書いてください。

```
## 概要

## 変更内容

## レビュアーへの補足情報

## 手動でテストが必要な箇所(チェックボックス有りで最大10個)

```

# その他
* チャット内の回答は日本語でお願いします。
* @mainが定義されているファイルは`TimesTablesAppApp.swift`です