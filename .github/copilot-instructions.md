# このソースコードの説明

* このアプリはSwiftで書かれたiOSアプリです。
  * 九九ができるアプリになる予定です。

# 今後実装する機能(上から優先度高)

## 1. 九九チャレンジ機能（基本の学習部分）

* 1-1. 問題が出題される（ランダム or ◯の段ごと）
* 1-2. ユーザーが回答できる
* 1-3. 正解・不正解を判定し、ポイントを加算
* 1-4. 間違えた問題の記録（「苦手」認定のため）

## 2. ポイントシステム

* 2-1. 正解したらポイントGET
* 2-2. 苦手な問題のポイントUP（最初は固定でもOK）
* 2-3. 獲得ポイントを一覧で見れる

## 3. 親の管理画面（最低限）

* 3-1. 子どものポイントを確認できる
* 3-2. ポイントのリセット or 交換（指定ポイントの消費）

# 要件

* コードを追加した場合はビルドしてコンパイルエラーが発生していないか確認し、エラーがある場合は解消してから再度ビルドして確かめてください。
* テストコードはswift-testingで書いてください。XCTestは極力書かないでください。
  * ViewStateのテストは必ず書いてください。
* 既存コードの修正、テストコードを追加・修正した場合はテストを実行してエラーが発生していないか確認し、エラーがある場合は解消してから再度ビルドして確かめてください。
  * ただし、現状テストコードの実行時Agentはコマンド実行完了を待てない場合があるので、一度実行して結果を取得できない場合はテストの手動実行を依頼してください。
* 意図の把握が難しい関数がある場合はSwiftDocを記載してください。可能なら意図がわかるように実装してください。
* このアプリのプライマリー言語は日本語ですが、英語も対応しています。日本語のテキストを追加した場合は英語対応も必要です。

# このアプリで利用されているSVVSアーキテクチャについての説明
  
* SVVSでは、ViewのアクションがViewStateを通じてStoreに伝達されます。StoreはAPIやDBと通信し、シングルトンでデータを保持します。
* Storeのデータ変更はViewStateを介してViewに反映され、単方向データフローを実現します。

# テストコードについての補足

* ViewStateのテストコードはstructの定義の上に`@MainActor`が必要です。

# 動作確認について

* ビルドは以下のコマンドで行ってください。
```
xcodebuild -scheme ParentFeel \
  -configuration Debug \
  -workspace ParentFeel/ParentFeel.xcodeproj/project.xcworkspace \
  -destination 'id=B3F517A2-0287-4161-9C05-0C71FA26DF92' \
  -allowProvisioningUpdates build | xcbeautify
```
* テストの実行は以下のコマンドで行ってください。
```
xcodebuild -scheme ParentFeel \
  -configuration Debug \
  -workspace ParentFeel/ParentFeel.xcodeproj/project.xcworkspace \
  -destination 'id=B3F517A2-0287-4161-9C05-0C71FA26DF92' \
  -destination-timeout 60 \
  -only-testing:ParentFeelTests test \
  -verbose | xcbeautify
```

# PRのレビューコメント取得について

以下の方法で取得してください。

```
% gh api repos/{owner}/{repo}/pulls/{pull_number}/reviews
% gh api repos/{owner}/{repo}/pulls/{pull_number}/reviews/{review_id}/comments
```

{owner}=y-hirakaw
{repo}=times_tables_ios

# PR作成について

* ghコマンドはインストール済みです。
* 以下のフォーマットで対応内容をPRに書いてください。

```
## 概要

## 変更内容

## レビュアーへの補足情報

## 手動でテストが必要な箇所(チェックボックス有りで最大10個)

```

# その他
* チャット内の回答は日本語でお願いします。