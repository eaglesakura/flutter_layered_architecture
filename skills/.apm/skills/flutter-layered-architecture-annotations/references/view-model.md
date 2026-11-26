# `@viewModel`

画面向け ViewModel に付与する。`@stateful` の制約を引き継ぎ、表示用 `entity` とメソッド命名を追加で要求する。

## いつ付けるか

* Screen 層の ViewModel を新規作成・改修するとき
* Widget から触る状態・イベント入口を ViewModel に閉じるとき

`@stateful` を二重に書く必要はない。`@viewModel` だけで stateful 系 lint も対象になる。

## 付与先

* **型**
* バレル `library` には付けない

## 必須併記

* `@internal`（`package:meta`）を併記する
* `MutableStateStream<T>` の **ルート** `T` には [`@state`](./state.md)
* `entity` の **ルート** `T` には [`@entity`](./entity.md)

## 付与後に効く Lint

### `@viewModel` 固有

| Lint code | 要点 |
| --- | --- |
| `viewmodel_internal` | `@internal` 併記 |
| `viewmodel_has_entity_getter` | `StateStream<T> get entity` を宣言 |
| `viewmodel_entity_annotated` | `entity` の `T` に `@entity` 必須（構造はゲート A） |
| `viewmodel_entity_differs_from_state` | `entity` のモデル型は `MutableStateStream` の状態型と異なる |
| `viewmodel_on_method_names` | インスタンス／extension メソッドは `on...`（`close` / `_close` 除く） |

### 継承する `@stateful` 系

| Lint code | 要点 |
| --- | --- |
| `stateful_immutable` | final フィールド + const コンストラクタ |
| `stateful_has_mutable_state_stream` | `MutableStateStream` フィールド |
| `stateful_closes_mutable_state_stream` | `close` 経路あり |
| `stateful_mutable_state_stream_state` | 状態モデルに `@state` |
| `stateful_methods_use_delegate` | 処理は `@delegate.execute` へ |

詳細は次の SKILL を正とする。

* `flutter-layered-architecture-linter-rule-viewmodel-internal`
* `flutter-layered-architecture-linter-rule-viewmodel-has-entity-getter`
* `flutter-layered-architecture-linter-rule-viewmodel-entity-annotated`
* `flutter-layered-architecture-linter-rule-viewmodel-entity-differs-from-state`
* `flutter-layered-architecture-linter-rule-viewmodel-on-method-names`
* および `flutter-layered-architecture-linter-rule-stateful-*`

## 推奨形

* 内部状態（State）と表示モデル（Entity）を分ける
* Widget 向けアクションは `onAddTodo` のように `on` 接頭辞
* アクション本体は同名イメージの `@delegate` に委譲する
* 初期状態は `TodoListScreenState(isLoading: true, ...)` のように主 factory で全引数を渡す

## 良い例

```dart
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:meta/meta.dart';

@internal
@viewModel
final class TodoListScreenViewModel {
  const TodoListScreenViewModel({
    required this.state,
    required this.stateToEntityDelegate,
  });

  final MutableStateStream<TodoListScreenState> state;
  final TodoListScreenStateToEntityDelegate stateToEntityDelegate;

  StateStream<TodoListScreenEntity> get entity =>
      state.map(stateToEntityDelegate.execute);

  Future<void> _close() => state.close();
}

extension TodoListScreenViewModelActions on TodoListScreenViewModel {
  Future<void> onAddTodo() {
    return OnAddTodoDelegate(state: state, ...).execute();
  }
}
```

（`TodoListScreenState` / `TodoListScreenEntity` にそれぞれ `@state` / `@entity` を付与する。）

## 悪い例

```dart
@viewModel // @internal なし → viewmodel_internal
final class BadViewModel {
  // entity なし → viewmodel_has_entity_getter
  // MutableStateStream なし → stateful_has_mutable_state_stream
  Future<void> addTodo() async {} // on* でない・delegate 未使用
}
```

## DO NOT

* State と Entity を同じ型にしない
* `close` / `_close` 以外のメソッドを `on` 以外の名前にしない
* `@stateful` だけ付けて画面 ViewModel の追加規約を逃さない
* Freezed だけ付けて `@state` / `@entity` を省略しない