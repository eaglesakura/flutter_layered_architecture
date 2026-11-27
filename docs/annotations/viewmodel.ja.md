# @viewModel

画面向け ViewModel 型を示すアノテーションである。`@stateful` の制約を引き継ぎ、表示用 `entity` とメソッド命名の規約を追加して `flutter_layered_architecture_lint` が構造を検証できるようにする。

## Details

DO Screen 層の ViewModel に `@viewModel` を付与する。`@stateful` を二重に書く必要はない。`@viewModel` だけで stateful 系 lint も対象になる。併記として `@internal`（`package:meta`）が必須である。

継承する `@stateful` の制約:

* フィールドはすべて `final`/`const`、コンストラクタは `const`
* `MutableStateStream<T>` を持ち、ルート `T` には `@state` が必須
* いずれかの経路で `MutableStateStream.close()` を呼ぶ
* インスタンス／extension メソッドの処理は `@delegate.execute` へ委譲（`close` / `_close` は例外）

ViewModel 固有の追加規約:

* `StateStream<T> get entity` を宣言し、ルート `T` には `@entity` が必須（構造はゲート A）
* `entity` のモデル型は `MutableStateStream` の状態モデル型と異なる
* インスタンス／extension メソッド（`close` / `_close` を除く）は名前が `on` で始まる

関連 lint の Severity: WARNING。

BAD:

```dart
@viewModel
final class BadViewModel {
  Future<void> addTodo() async {}
}
```

GOOD:

```dart
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

## Usage

Import:

```dart
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
```

`@internal` 用に `package:meta/meta.dart` も import する。

付与先: 型。バレル `library` には付けない。

## Related linter rules

* [viewmodel_internal](../linter-rules/viewmodel_internal.ja.md)
* [viewmodel_has_entity_getter](../linter-rules/viewmodel_has_entity_getter.ja.md)
* [viewmodel_entity_annotated](../linter-rules/viewmodel_entity_annotated.ja.md)
* [viewmodel_entity_differs_from_state](../linter-rules/viewmodel_entity_differs_from_state.ja.md)
* [viewmodel_on_method_names](../linter-rules/viewmodel_on_method_names.ja.md)
* [stateful_immutable](../linter-rules/stateful_immutable.ja.md)
* [stateful_has_mutable_state_stream](../linter-rules/stateful_has_mutable_state_stream.ja.md)
* [stateful_closes_mutable_state_stream](../linter-rules/stateful_closes_mutable_state_stream.ja.md)
* [stateful_mutable_state_stream_state](../linter-rules/stateful_mutable_state_stream_state.ja.md)
* [stateful_methods_use_delegate](../linter-rules/stateful_methods_use_delegate.ja.md)
