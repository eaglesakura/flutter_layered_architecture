# viewmodel_internal

`@viewModel` 型には `@internal` を併記する。

## Details

DO `@viewModel` 型に `@internal`（`package:meta`）を付ける。ViewModel は Screen パッケージ内の実装詳細として扱い、公開 API にしない。

Severity は WARNING である。

関連アノテーション: `@viewModel`。`@viewModel` は `@stateful` のルール（`stateful_immutable`、`stateful_has_mutable_state_stream`、`stateful_closes_mutable_state_stream`、`stateful_mutable_state_stream_state`、`stateful_methods_use_delegate`）も引き継ぐ。

BAD:

```dart
@viewModel
final class TodoListScreenViewModel {
  const TodoListScreenViewModel({required this.state});

  final MutableStateStream<TodoListScreenState> state;
}
```

GOOD:

```dart
@internal
@viewModel
final class TodoListScreenViewModel {
  const TodoListScreenViewModel({required this.state});

  final MutableStateStream<TodoListScreenState> state;
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
// ignore: flutter_layered_architecture_lint/viewmodel_internal
```
