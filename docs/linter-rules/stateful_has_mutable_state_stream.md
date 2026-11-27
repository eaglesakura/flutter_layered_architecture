# stateful_has_mutable_state_stream

`@stateful` types must declare at least one `MutableStateStream` field.

## Details

DO declare at least one `MutableStateStream` field on every `@stateful` / `@viewModel` type. Mutable state is concentrated there rather than in ad-hoc mutable fields. Also applies to `@viewModel` (inherits `@stateful`). Severity: WARNING.

Related annotations: `@stateful`, `@viewModel`.

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

This rule ships with the `flutter_layered_architecture_lint` analyzer plugin. Enable the plugin in the workspace root `analysis_options.yaml`:

```yaml
plugins:
  flutter_layered_architecture_lint:
    path: packages/lint
```

Requires Dart 3.14+ (Flutter 3.50+). After changing `plugins:`, restart the Dart Analysis Server.

## Suppress

```dart
// ignore: flutter_layered_architecture_lint/stateful_has_mutable_state_stream
```
