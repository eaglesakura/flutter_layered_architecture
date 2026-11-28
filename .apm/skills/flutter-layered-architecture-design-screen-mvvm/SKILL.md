---
name: flutter-layered-architecture-design-screen-mvvm
description: >-
  Flutter Layered Architecture の Screen 層 MVVM 設計用 SKILL。
  1 画面 1 ViewModel、State / Entity / Event の役割分担、Screen / ScreenImpl、
  `onXXXX` + 使い捨て Delegate、`onInitialize` の起動位置、watch/read の使い分け、
  updateWithLock の短いロック、画面固有 Usecase、ViewModel テスト方針を扱う。
  「画面を作る」「ViewModel 追加」「Entity 設計」「onInitialize」でも必ず使う。
  `@viewModel` / `@state` / `@entity` / `@delegate` は
  flutter-layered-architecture-annotations、
  viewmodel_* / stateful_* / state_entity_* / delegate_* は対応する
  flutter-layered-architecture-linter-rule-*、
  Usecase / Repository は design-usecase / design-repository、
  画面遷移は flutter-layered-architecture-screen-navigation、
  所在調査は code-search を使う。
---
# Flutter Layered Architecture / Screen 層 MVVM

Screen 層は **Model–View–ViewModel** で組む。
可変状態は ViewModel の State、表示は Entity、操作は `onXXXX()`、見た目は Widget。

構造の機械的保証（`@viewModel` / `@state` / `@entity` / `@delegate` と連動 lint）は Annotations / Linter が担う。
本 SKILL は lint が見ない設計判断（役割分担・起動位置・watch/read・ロック・ファイル分割）に限定する。

正本の例: `@flutter_layered_architecture/example/screen/feature/todo_list/`。

## スコープ外（別正本）

| 関心 | 正本 |
| --- | --- |
| Annotation 付与の詳細・連動 lint | `flutter-layered-architecture-annotations`（推奨一覧は本 SKILL「推奨 Annotation」） |
| `viewmodel_*` | `flutter-layered-architecture-linter-rule-viewmodel-*` |
| `stateful_*` | `flutter-layered-architecture-linter-rule-stateful-*` |
| `state_entity_*` | `flutter-layered-architecture-linter-rule-state-entity-*` |
| `delegate_*` | `flutter-layered-architecture-linter-rule-delegate-*` |
| Usecase / Repository | `design-usecase` / `design-repository` |
| 画面遷移・Factory / Launcher | `flutter-layered-architecture-screen-navigation` |
| package 所属 | `flutter-layered-architecture-resolve-package-layer` |
| workspace | `flutter-layered-architecture-workspace` |

## いつ使うか

* Screen の ViewModel / State / Entity / Event / Widget を新規・改修するとき
* `onXXXX` の切り方、`onInitialize` の起動位置、watch/read の方針
* ViewModel Unit Test の組み立て

## 作業手順

1. 1 画面の ViewModel 境界を決める（タブ親子などスコープが互いに素なら複数可）
2. State（可変）・Entity（表示）・Event（ワンショット）の役割を分ける
3. 下表の Annotation を付け、lint を満たす骨格を置く（annotations / linter-rule）
4. Screen / ScreenImpl・`onXXXX`・必要なら画面固有 Usecase を整える（`references/`）
5. 遷移が必要なら `screen-navigation` へ

## 推奨 Annotation

付与位置・併記・連動 lint の正本は `flutter-layered-architecture-annotations`（各 `references/`）。
ここでは Screen MVVM 設計時に **付けるもの** を示す。

| 対象 | Annotation | 備考 |
| --- | --- | --- |
| ViewModel | `@viewModel` + `@internal` | `@stateful` は二重に書かない（制約は `@viewModel` が継承） |
| ScreenState（`MutableStateStream<T>` の `T`） | `@state` + `@internal` + `@freezed` | ルート `T` に必須。`@entity` と同一型にしない |
| ScreenEntity（`entity` の `T`） | `@entity` + `@internal` + `@freezed` | ルート `T` に必須。State と型を分ける |
| ScreenEvent | （FLA 型 annotation なし） | Freezed 等は可。`@state` / `@entity` は付けない |
| `onXXXX` 本体・State→Entity 変換 | `@delegate` + `@internal` | 使い捨て。フィールドに Delegate を保持しない（変換用は例外的に VM へ注入可） |
| 画面固有 Usecase | `@usecase` | 切り出し判断は `design-usecase` |
| Widget / Screen / ScreenImpl | （なし） | FLA 型 annotation は付けない |

* ネストしたリスト項目 Entity 等への `@entity` は任意（ルートのみ必須）
* 詳細は annotations の `view-model.md` / `state.md` / `entity.md` / `delegate.md`

## 役割分担（lint が見ない判断）

| 要素 | 役割 |
| --- | --- |
| ScreenState | 画面の可変真実。Repository / Usecase インスタンスは載せない。冪等に再計算できる値も載せない |
| ScreenEntity | View 向け表示モデル。State と型を分ける（lint: `viewmodel_entity_differs_from_state`） |
| ScreenEvent | 一過性の副作用（snackbar 等）。表示の定常切替には使わない |
| ViewModel | DI・ライフサイクル・`state` / `entity` /（任意）`event` の入口 |
| Widget | 見た目とユーザー入力。ビジネスロジックは書かない |

## 原則（要約）

* **1 画面 = 1 ViewModel**（スコープが独立なら柔軟に）
* Riverpod は **DI とライフサイクル**に限る。`Provider.autoDispose` を手書きする（**`@riverpod` は使わない**）
* ルートは `{画面名}Screen`（public）、見た目は `{画面名}ScreenImpl`。子は **Entity のみ watch**、操作は `ref.read`
* 操作は **`onXXXX()`**（lint: `viewmodel_on_method_names`）。本体は `.action.dart` の **使い捨て Delegate**（フィールド保持しない）
* **非同期初期化は `onInitialize()`**。コンストラクタ / Provider から呼ばず、ルート Screen の `useEffect` 等から呼ぶ
* `updateWithLock` 内は短い状態遷移のみ。I/O・RPC はロック外
* 画面 dispose で解放するリソース（キャンセル用コンテキスト等）は **State に載せる**（VM フィールドに置かない）
* 画面遷移は `screen-navigation`。`go_router` / `Navigator` を画面 package から直叩きしない
* Widget は Stateless 系（`HookConsumerWidget` 等）。`StatefulWidget` は作らない

## 主なライブラリ

| 用途 | パッケージ |
| --- | --- |
| 状態・DI | `flutter_riverpod` / `hooks_riverpod` / `flutter_hooks` |
| State ストリーム | `state_stream` / `state_stream_riverpod` |
| 深い比較 watch | `flutter_riverpod_watch_plus`（`watchBy`） |
| 不変データ | `freezed`（State / Entity / Event） |
| VM テスト | `riverpod_container_async_test` 等 |

## 追加ドキュメント

| 参照 | 使うとき |
| --- | --- |
| [view-and-widget.md](./references/view-and-widget.md) | Screen / ScreenImpl、watch/read、初期化 |
| [action-and-delegate.md](./references/action-and-delegate.md) | `onXXXX`、使い捨て Delegate、短いロック |
| [state-entity-event.md](./references/state-entity-event.md) | State / Entity / Event の設計判断 |
| [testing.md](./references/testing.md) | ViewModel / Delegate テスト |

## 最小の形（example）

```dart
@internal
@viewModel
final class TodoListScreenViewModel {
  static final provider = Provider.autoDispose<TodoListScreenViewModel>(...);
  final MutableStateStream<TodoListScreenState> state; // T に @state
  StateStream<TodoListScreenEntity> get entity =>       // T に @entity
      state.map(stateToEntityDelegate.execute);        // Delegate は @delegate
}
```

```dart
final class TodoListScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(TodoListScreenViewModel.provider);
    useEffect(() {
      viewModel.onInitialize();
      return null;
    }, [viewModel]);
    return const TodoListScreenImpl();
  }
}
```

## ナレッジベース

### DO: まず役割（State / Entity / Event / Widget）を決めてから型を切る

* annotation 付与の前に、何が可変真実で何が表示かを固定する

### DO: 表示は Entity、操作は onXXXX、可変は State ストリーム

* View が State や Repository を直接いじるとテストと責務が崩れる

### DO NOT: Linter / Annotations が見る構造を本 SKILL に再掲する

* `@internal`・`entity` getter・`on` 接頭辞・Delegate 委譲・Freezed 構築は各正本へ

### DO NOT: 初期化や購読開始をコンストラクタ / Provider から行う

* 画面の mount に紐づける（ルート Screen）

### DO NOT: 画面 package からルーターを直叩きする

* 遷移は `screen-navigation`
