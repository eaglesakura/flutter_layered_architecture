# delegate_immutable

`@delegate` 型は final フィールドと const コンストラクタを持つ。

## Details

DO `@delegate` 型のフィールドをすべて `final` または `const` にし、`const` コンストラクタを 1 つ以上宣言する。依存と state 参照は final とし、`const` で組み立て可能にする。

Severity は WARNING である。

関連アノテーション: `@delegate`、`@internal`。

BAD:

```dart
@internal
@delegate
final class Bad {
  Bad(this.state);
  MutableStateStream<TodoListScreenState> state;

  Future<void> execute() async {}
}
```

GOOD:

```dart
@internal
@delegate
final class OnInitializeDelegate {
  const OnInitializeDelegate({
    required this.state,
    required this.listTodosUsecase,
  });

  final MutableStateStream<TodoListScreenState> state;
  final ListTodosUsecase listTodosUsecase;

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
// ignore: flutter_layered_architecture_lint/delegate_immutable
```
