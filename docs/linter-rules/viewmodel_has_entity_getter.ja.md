# viewmodel_has_entity_getter

`@viewModel` 型は `StateStream<T> get entity` を宣言する。

## Details

DO `@viewModel` 型に `StateStream<T> get entity` を宣言する。View は内部の `MutableStateStream` ではなく entity を watch する。State から Entity への変換は、必要に応じて `state.map` と `@delegate` で行う。

Severity は WARNING である。

関連アノテーション: `@viewModel`。関連ルール: `viewmodel_entity_annotated`、`viewmodel_entity_differs_from_state`。`@viewModel` は `@stateful` のルールも引き継ぐ。

BAD:

```dart
@internal
@viewModel
final class Bad {
  const Bad({required this.state});

  final MutableStateStream<TodoListScreenState> state;
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
// ignore: flutter_layered_architecture_lint/viewmodel_has_entity_getter
```
