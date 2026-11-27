# stateful_has_mutable_state_stream

`@stateful` 型は `MutableStateStream` フィールドを持つ。

## Details

DO `@stateful` / `@viewModel` 型に `MutableStateStream` フィールドを少なくとも 1 つ宣言する。可変状態はバラの可変フィールドではなくそこに集約する。`@viewModel` にも適用する（`@stateful` を継承する）。Severity は WARNING である。

関連アノテーション: `@stateful`, `@viewModel`。

BAD:

```dart
@stateful
final class Bad {
  const Bad({required this.title});
  final String title;
}
```

GOOD:

```dart
@stateful
final class Store {
  const Store({required this.state});
  final MutableStateStream<StoreState> state;
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
// ignore: flutter_layered_architecture_lint/stateful_has_mutable_state_stream
```
