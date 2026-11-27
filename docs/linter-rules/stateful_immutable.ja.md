# stateful_immutable

`@stateful` 型は final フィールドと const コンストラクタを持つ。

## Details

DO `@stateful` / `@viewModel` 型のフィールドをすべて `final` または `const` にし、`const` コンストラクタを少なくとも 1 つ置く。可変状態は型の差し替え可能フィールドではなく `MutableStateStream` に置く。`@viewModel` にも適用する（`@stateful` を継承する）。Severity は WARNING である。

関連アノテーション: `@stateful`, `@viewModel`。

BAD:

```dart
@stateful
final class Bad {
  Bad(this.state);
  MutableStateStream<StoreState> state;
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
// ignore: flutter_layered_architecture_lint/stateful_immutable
```
