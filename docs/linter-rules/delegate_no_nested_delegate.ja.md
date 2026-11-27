# delegate_no_nested_delegate

`@delegate` が別の `@delegate` を受け取ったり生成したりしない。

## Details

DO NOT 別の `@delegate` 型をコンストラクタ引数に取らない。`@delegate` クラス内で別の `@delegate` 型を生成しない。Delegate の入れ子は依存グラフを複雑にする。共通処理は Usecase やヘルパーへ寄せ、Delegate は画面操作単位に保つ。

`@usecase` 依存はコンストラクタ注入してよい。Severity は WARNING である。

関連アノテーション: `@delegate`。

BAD:

```dart
@internal
@delegate
final class Outer {
  const Outer({required this.inner});

  final OtherDelegate inner;

  Future<void> execute() async {}
}
```

GOOD:

```dart
@internal
@delegate
final class OnAddTodoDelegate {
  const OnAddTodoDelegate({required this.addTodoUsecase});

  final AddTodoUsecase addTodoUsecase;

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
// ignore: flutter_layered_architecture_lint/delegate_no_nested_delegate
```
