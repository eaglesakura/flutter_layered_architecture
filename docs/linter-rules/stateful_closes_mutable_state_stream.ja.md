# stateful_closes_mutable_state_stream

`@stateful` 型内のいずれかの経路で `MutableStateStream.close()` を呼ぶ。

## Details

DO `@stateful` / `@viewModel` 型内のいずれかの経路で `MutableStateStream.close()` を呼ぶ（典型的には `close` / `_close`）。`MutableStateStream` フィールドが無い型は `stateful_has_mutable_state_stream` が扱う。`@viewModel` にも適用する（`@stateful` を継承する）。Severity は WARNING である。

関連アノテーション: `@stateful`, `@viewModel`。

BAD:

```dart
@stateful
final class Bad {
  const Bad({required this.state});
  final MutableStateStream<StoreState> state;
}
```

GOOD:

```dart
@stateful
final class Store {
  const Store({required this.state});
  final MutableStateStream<StoreState> state;
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
// ignore: flutter_layered_architecture_lint/stateful_closes_mutable_state_stream
```
