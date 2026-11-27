# delegate_no_usecase_instantiation

`@delegate` 内で `@usecase` 型を生成しない（コンストラクタ注入する）。

## Details

DO `@usecase` 依存はコンストラクタで注入する。DO NOT `@delegate` クラス内で `@usecase` 型を new しない。生成責務を Delegate の外に置くと、テスト時の差し替えが容易である。

Severity は WARNING である。

関連アノテーション: `@delegate`、`@usecase`。

BAD:

```dart
@internal
@delegate
final class Bad {
  const Bad();

  Future<void> execute() async {
    await AddTodoUsecaseImpl().execute(request);
  }
}
```

GOOD:

```dart
@internal
@delegate
final class OnAddTodoDelegate {
  const OnAddTodoDelegate({required this.addTodoUsecase});

  final AddTodoUsecase addTodoUsecase;

  Future<void> execute() => addTodoUsecase.execute(request);
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
// ignore: flutter_layered_architecture_lint/delegate_no_usecase_instantiation
```
