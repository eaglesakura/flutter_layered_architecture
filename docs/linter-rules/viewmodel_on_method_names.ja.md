# viewmodel_on_method_names

`@viewModel` のインスタンス / extension メソッドは `on...` で始める（`close` / `_close` 除く）。

## Details

DO `@viewModel` 型のインスタンスメソッドおよび extension method を `on` 始まりにする（例: `onAddTodo`、`onInitialize`）。タップなどの画面イベントに揃える。getter / setter は対象外である。`close` と `_close` はストリーム破棄用の例外として許容する。

Severity は WARNING である。

関連アノテーション: `@viewModel`。関連ルール: `stateful_methods_use_delegate`（アクションは `@delegate.execute` を呼ぶ）。

BAD:

```dart
extension on TodoListScreenViewModel {
  Future<void> addTodo() async {}
}
```

GOOD:

```dart
@internal
@viewModel
final class TodoListScreenViewModel {
  Future<void> _close() => state.close();
}

extension TodoListScreenViewModelActions on TodoListScreenViewModel {
  Future<void> onAddTodo() {
    return OnAddTodoDelegate(
      state: state,
      addTodoUsecase: addTodoUsecase,
    ).execute();
  }
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
// ignore: flutter_layered_architecture_lint/viewmodel_on_method_names
```
