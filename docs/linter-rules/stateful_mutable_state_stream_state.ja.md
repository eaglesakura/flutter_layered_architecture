# stateful_mutable_state_stream_state

`@stateful` 上の `MutableStateStream` 型引数は `@state` 付き class にする。

## Details

DO `@stateful` / `@viewModel` 型の `MutableStateStream<T>` について、ルート型引数 `T` に `@state` を付ける。Freezed 等の構造は `@state` 型に対する `state_entity_*` が検査する。`T` が Freezed のみでは不足である。`@viewModel` にも適用する（`@stateful` を継承する）。Severity は WARNING である。

関連アノテーション: `@stateful`, `@viewModel`, `@state`。

BAD:

```dart
@freezed
abstract class StoreState with _$StoreState {
  const factory StoreState({required String title}) = _StoreState;
}

@stateful
final class Store {
  const Store({required this.state});
  final MutableStateStream<StoreState> state;
}
```

GOOD:

```dart
@internal
@state
@freezed
abstract class StoreState with _$StoreState {
  const factory StoreState({required String title}) = _StoreState;
}

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
// ignore: flutter_layered_architecture_lint/stateful_mutable_state_stream_state
```
