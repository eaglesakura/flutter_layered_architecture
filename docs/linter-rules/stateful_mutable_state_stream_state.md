# stateful_mutable_state_stream_state

`MutableStateStream` type argument on `@stateful` types must be a class annotated with `@state`.

## Details

DO annotate the root type argument `T` of every `MutableStateStream<T>` on a `@stateful` / `@viewModel` type with `@state`. This checks only the annotation on the root type argument; Freezed and other structure checks are `state_entity_*` on the `@state` type itself. Freezed alone on `T` is not enough. Also applies to `@viewModel` (inherits `@stateful`). Severity: WARNING.

Related annotations: `@stateful`, `@viewModel`, `@state`.

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

This rule ships with the `flutter_layered_architecture_lint` analyzer plugin. Enable the plugin in the workspace root `analysis_options.yaml`:

```yaml
plugins:
  flutter_layered_architecture_lint:
    path: packages/lint
```

Requires Dart 3.14+ (Flutter 3.50+). After changing `plugins:`, restart the Dart Analysis Server.

## Suppress

```dart
// ignore: flutter_layered_architecture_lint/stateful_mutable_state_stream_state
```
