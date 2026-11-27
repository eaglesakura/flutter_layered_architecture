# delegate_execute_method

`@delegate` 型のインスタンスメソッドはちょうど 1 つで、名前は `execute` とする。

## Details

DO `@delegate` 型にインスタンスメソッドをちょうど 1 つ宣言し、名前を `execute` にする。引数の有無と戻り値型は任意である。Delegate は単一処理ユニットであり、入口は常に `execute` である。

Severity は WARNING である。

関連アノテーション: `@delegate`、`@internal`。

BAD:

```dart
@internal
@delegate
final class Bad {
  const Bad();

  Future<void> run() async {}
}
```

GOOD:

```dart
@internal
@delegate
final class OnAddTodoDelegate {
  const OnAddTodoDelegate({required this.state});

  final MutableStateStream<TodoListScreenState> state;

  Future<void> execute() async {
    // ...
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
// ignore: flutter_layered_architecture_lint/delegate_execute_method
```
