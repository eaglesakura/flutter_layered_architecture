# 実体優先と Mock の境界

## 既定: 実体

`testing_injection` で結線した **本番 Impl** を `ref.testReady(IF.provider)` で取り、振る舞いを検証する。

* Usecase の変換・集約・分岐
* InMemory / Embedded 等で閉じる Repository
* Infra が Testing\* で十分に置き換わっている経路

これにより「DI で差し替え可能」と「結合したロジックが正しい」を同時に担保する。

## Mock / Testing\* を使うとき

次に該当するときだけ Mock（mocktail 等）または厚い Testing\* を使う。

1. **Unit Test では再現できない外部**
   * 実ネットワークかつ認証が必須
   * 実機・OS 権限・課金などホスト外の前提が要る
2. **故障・エラー経路の再現**
   * タイムアウト、5xx、認証切れなど、実体では安定して起きにくい事象
3. **画面・VM シナリオで依存を固定したいとき**
   * Repository の戻りをシナリオごとに固定する（既存の Screen テスト慣例）
   * それでも「検証対象のロジック Usecase」自体は実体のままが望ましい

## 優先順位（再利用）

`design-repository` の testing と整合させる。

1. **実体**（本 SKILL の既定）
2. **Testing\***（振る舞いが厚く Mock だと読めない）
3. **Mock**（戻り固定・故障注入）

「emit 用ヘルパーだけ」の Testing\* は作らない。Mock で足りるなら `_testing` package 自体を作らない。

## DO / DO NOT

### DO

* まず `injectForTesting` + 実体で書けるか試す
* Mock するなら **境界の IF**（外部 Repository / クライアント）に限る
* 故障注入の意図をテスト名またはコメントで残す

### DO NOT

* 検証対象の Usecase を Mock して「呼ばれたこと」だけを assert する（実体で実行できるなら）
* すべての依存を Mock してからテストを書くことを既定にする
* 本番 Impl に `if (isTest)` で Fake を混ぜる
