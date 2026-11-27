# delegate_internal

`@delegate` 型には `@internal` を併記する。

## Details

DO すべての `@delegate` 型に `@internal`（`package:meta`）を併記する。Delegate はパッケージ内の実装詳細であり、公開 API として扱わない。

Severity は WARNING である。

関連アノテーション: `@delegate`、`@internal`。

BAD:

```dart
@delegate
final class OnAddTodoDelegate {
  const OnAddTodoDelegate();

  Future<void> execute() async {}
}
```

GOOD:

```dart
@internal
@delegate
final class OnAddTodoDelegate {
  const OnAddTodoDelegate();

  Future<void> execute() async {}
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
// ignore: flutter_layered_architecture_lint/delegate_internal
```
