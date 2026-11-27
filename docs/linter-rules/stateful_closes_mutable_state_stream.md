# stateful_closes_mutable_state_stream

`@stateful` types must call `MutableStateStream.close()` somewhere in the class.

## Details

DO call `MutableStateStream.close()` on some path inside the `@stateful` / `@viewModel` type (typically `close` / `_close`). Types without a `MutableStateStream` field are handled by `stateful_has_mutable_state_stream` instead. Also applies to `@viewModel` (inherits `@stateful`). Severity: WARNING.

Related annotations: `@stateful`, `@viewModel`.

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

This rule ships with the `flutter_layered_architecture_lint` analyzer plugin. Enable the plugin in the workspace root `analysis_options.yaml`:

```yaml
plugins:
  flutter_layered_architecture_lint:
    path: packages/lint
```

Requires Dart 3.14+ (Flutter 3.50+). After changing `plugins:`, restart the Dart Analysis Server.

## Suppress

```dart
// ignore: flutter_layered_architecture_lint/stateful_closes_mutable_state_stream
```
