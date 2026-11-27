# viewmodel_entity_differs_from_state

`@viewModel` の `entity` モデル型は、`MutableStateStream` の状態モデル型と異なる必要がある。

## Details

DO `entity` と主たる `MutableStateStream<T>` フィールドのモデル型を別にする。State はドメイン寄り、Entity は表示寄りに分離し、View が内部状態に結合しないようにする。

Severity は WARNING である。

関連アノテーション: `@viewModel`。関連ルール: `viewmodel_has_entity_getter`、`viewmodel_entity_annotated`。State モデルは `@state`、Entity モデルは `@entity` を使う。

BAD:

```dart
@internal
@viewModel
final class Bad {
  const Bad({required this.state});

  final MutableStateStream<TodoListScreenState> state;

  StateStream<TodoListScreenState> get entity => state;
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
}
```

## Enable

本ルールは `flutter_layered_architecture_lint` analyzer プラグインに含まれる。ワークスペースルートの `analysis_options.yaml` でプラグインを有効化する:

```yaml
plugins:
  flutter_layered_architecture_lint:
    path: packages/lint
```

Dart 3.14+（Flutter 3.50+）が必要である。`plugins:` を変更したら Dart Analysis Server を再起動する。

## Suppress

```dart
// ignore: flutter_layered_architecture_lint/viewmodel_entity_differs_from_state
```
