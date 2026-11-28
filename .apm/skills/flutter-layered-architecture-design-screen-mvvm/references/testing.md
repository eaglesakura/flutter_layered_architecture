# ViewModel / Delegate テスト

## 基本

* ViewModel は **Provider 経由**で取得する（テストでも直接 `new` しない）
* Repository 依存は **Mock + overrideWithValue** を既定とする（`design-repository` の testing と同方針）
* `injectForTesting` の後、必要な依存だけ差し替える

## 検証パターン

* **推奨**: `state` / `entity` / `event` を Stream 監視して時系列で assert
* `event` を検証するとき **`nothing` を期待値に混ぜすぎない**（発火したバリアントに注目）
* 必要なら `@visibleForTesting` の `state` へ直接アクセスしてよいが、Stream 監視を優先する

## 分割テスト

* **Delegate** と **画面固有 Usecase** は単体でもテストする（ViewModel 結合だけに頼らない）
* グループは機能単位（初期化 / 追加 / トグル 等）で切る

## Golden / Widget

見た目回帰・Entity 固定注入・ScreenImpl 撮影は
`flutter-layered-architecture-design-golden-test` を正本とする（MVVM 画面では必須）。
