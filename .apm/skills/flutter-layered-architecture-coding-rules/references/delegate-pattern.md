# Delegate パターン（切り出し判断）

`@delegate` 付与・`execute` 1 つ・不変性・`@internal`・入れ子禁止・Usecase 生成禁止は
**`flutter-layered-architecture-annotations`（`references/delegate.md`）と `linter-rule-delegate-*`** が正本である。
画面 ViewModel の `onXXXX`・使い捨て方針は **`design-screen-mvvm`（`action-and-delegate.md`）** を正とする。

本ドキュメントは lint が見ない **いつ切るか・どこに置くか・どう名付けるか・寿命** だけを扱う。

## いつ切り出すか

* 親クラス（ViewModel / Repository / Stateful 実装など）のメソッドが肥大化したとき
* 1 処理として独立してテストしたいとき
* 親はオーケストレーション（呼び出し）に留め、詳細は Delegate に閉じたいとき

目的は見通しと単一責務。レイヤー横断で同じ切り方を使う。

## 配置

親クラスと同じ package 内の `delegate/` 配下に置く。

```text
${親クラスを格納するディレクトリ}/
├── ${親クラス名}.dart
└── delegate/
    ├── ${処理名}_delegate.dart
    └── …
```

## 命名

* 型: `{処理内容}Delegate`（動詞句または名詞句）
* 画面操作: `OnAddTodoDelegate` のように `On…` を付けてよい
* データ処理: `SignInDelegate` / `DatabaseSyncDelegate` など処理名そのまま

## 寿命（インスタンス化）

| パターン | いつ使うか |
| --- | --- |
| 呼び出しごとに生成 | 依存がその都度変わる、または親フィールドを増やしたくない。**ViewModel の action Delegate は常にこちら**（`design-screen-mvvm`） |
| フィールドとして保持 | 同一 Delegate を繰り返し使う Repository 等（例: sync / edit）。`@stateful` 実装でも可 |

フィールド保持する場合も、Delegate 自身はステートレス（呼び出し間で内部状態を持たない）。状態は注入した `MutableStateStream` / Repository 側に置く。

## コンストラクタと execute 引数（設計判断）

* コンストラクタ: 親が持つ依存の **サブセット** だけを受け取る
* `execute` の引数・戻り値: 呼び出し元メソッドと揃える（構造の「メソッドは execute 1 つ」は lint）

## ナレッジベース

### DO: 肥大化したメソッドを 1 Delegate = 1 処理で切る

* 親にロジックを残さず、呼び出しだけにする

### DO: ViewModel action は使い捨て、Repository は必要ならフィールド保持

* 画面側の寿命規約は `design-screen-mvvm` と矛盾させない

### DO NOT: `@delegate` の構造ルールをここに再掲する

* 付与・併記・連動 lint は annotations / linter-rule へ
