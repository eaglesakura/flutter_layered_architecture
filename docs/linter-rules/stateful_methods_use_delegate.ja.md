# stateful_methods_use_delegate

`@stateful` / `@viewModel` のインスタンスメソッドは `@delegate` の `execute` へ委譲する（`close` / `_close` で `MutableStateStream` のみ閉じる場合は例外）。

## Details

DO `@stateful` / `@viewModel` のインスタンスメソッド（および当該型への extension）の業務処理を `@delegate` 型の `execute` 呼び出しに委譲する。`close` / `_close` で `MutableStateStream.close()` のみ行うメソッドは例外である。`@viewModel` にも適用する（`@stateful` を継承する）。Severity は WARNING である。

関連アノテーション: `@stateful`, `@viewModel`, `@delegate`。

BAD:

```dart
@viewModel
final class Bad {
  Future<void> onAddTodo() async {
    await state.updateWithLock((current) async => current);
  }
}
```

GOOD:

```dart
@viewModel
final class TodoListScreenViewModel {
  Future<void> onAddTodo() => OnAddTodoDelegate(...).execute();
  Future<void> close() => state.close();
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
// ignore: flutter_layered_architecture_lint/stateful_methods_use_delegate
```
