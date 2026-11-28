# Delegate パターン（切り出し判断）

`@delegate` 付与・`execute` 1 つ・不変性・`@internal`・入れ子禁止・Usecase 生成禁止は
**`flutter-layered-architecture-annotations`（`references/delegate.md`）と `linter-rule-delegate-*`** が正本である。
画面 ViewModel の `onXXXX`・使い捨て方針は **`design-screen-mvvm`（`action-and-delegate.md`）** を正とする。
ViewModel 結合テストの Stream 監視などは **`design-screen-mvvm`（`testing.md`）**、
Repository 差し替えの優先順位は **`design-repository`（`testing.md`）** を正とする。

本ドキュメントは lint が見ない **いつ切るか・どこに置くか・どう名付けるか・寿命・単体テスト** を扱う。

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

## 単体テスト

Delegate は ViewModel / Stateful 結合だけに頼らず、**単体で `execute` を直接呼ぶ**。
依存はすべてコンストラクタ注入し、Repository / Usecase 等を Mock（または Spy / Fake）に差し替えて成功・失敗を再現する。

### 単体テストの原則

* DI はコンストラクタ注入のみ。`execute` 内で依存を生成しない（lint: `delegate_no_usecase_instantiation`）
* テストでも親（ViewModel / Stateful）を経由せず、`XxxDelegate(...).execute(...)` を直接呼ぶ
* Repository / Usecase / RPC Client 等は Mock（mocktail 等）または package internal Fake / Spy を注入する
* `通信失敗`・タイムアウト・論理エラーは、Mock の `thenThrow` / Fake のエラーフラグで再現する

### `@stateful` / `@viewModel` 紐づき Delegate の状態遷移テスト

`MutableStateStream`（または同等の状態ホルダ）をコンストラクタで受け取る Delegate は、
**初期状態 → 操作（成功 / 失敗）→ 終了状態** をケースごとに検証する。

* 「XXXX の状態のとき、通信が失敗したら YYYY の状態になる」のように、開始状態と失敗結果を明示する
* 成功系だけでなく失敗系を足すことで、分岐・復帰・Event 発火のカバレッジが上がる
* 最終 `state` に加え、必要なら `event` の発火（Stream 監視）も assert する（詳細は `design-screen-mvvm` の `testing.md`）

### 単体テストの実装例

コンストラクタ注入と失敗再現の形である。依存の差し替え方針は `design-repository` の `testing.md` に従う。

```dart
// 提案テンプレート（Delegate 単体）
class _MockListTodosUsecase extends Mock implements ListTodosUsecase {}

test('idle のとき通信失敗したら loading が解け ready 相当へ戻る', () async {
  final state = MutableStateStream(
    const TodoListScreenState(isLoading: false, todos: []),
  );
  addTearDown(state.close);

  final usecase = _MockListTodosUsecase();
  when(() => usecase.execute(any())).thenThrow(Exception('network error'));

  await OnInitializeDelegate(
    state: state,
    listTodosUsecase: usecase,
  ).execute();

  expect(state.state.isLoading, isFalse);
  // 必要なら event / エラー表示用フィールドも assert する
});
```

状態遷移の観点例:

| 開始状態 | 操作・差し替え | 期待する終了状態 |
| --- | --- | --- |
| ready / idle | Repository が成功を返す | loaded / completed |
| ready / idle | Repository が例外を投げる | ready へ復帰 + 失敗 Event |
| loading 中 | 同一 action を再実行 | 二重実行しない / Repository を呼ばない |

## ナレッジベース

### DO: 肥大化したメソッドを 1 Delegate = 1 処理で切る

* 親にロジックを残さず、呼び出しだけにする

### DO: ViewModel action は使い捨て、Repository は必要ならフィールド保持

* 画面側の寿命規約は `design-screen-mvvm` と矛盾させない

### DO: Delegate 単体テストはコンストラクタ注入した Mock で失敗を再現する

* ViewModel 結合だけに頼らず、`execute` を直接呼ぶ
* 「XXXX のとき失敗 → YYYY」をケース化し、状態・Event の分岐を覆う

### DO NOT: `@delegate` の構造ルールをここに再掲する

* 付与・併記・連動 lint は annotations / linter-rule へ

### DO NOT: テストで親クラス経由だけにして失敗分岐を省略する

* 理由: 親結合では分岐網羅が薄く、Delegate 内の復帰・Event が未検証になりやすい
