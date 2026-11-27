# stateful_immutable

`@stateful` types must have only final fields and at least one const constructor.

## Details

DO keep every field on a `@stateful` / `@viewModel` type `final` or `const`, and provide at least one `const` constructor. Mutable state lives in `MutableStateStream`, not in replaceable fields on the type. Also applies to `@viewModel` (inherits `@stateful`). Severity: WARNING.

Related annotations: `@stateful`, `@viewModel`.

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

This rule ships with the `flutter_layered_architecture_lint` analyzer plugin. Enable the plugin in the workspace root `analysis_options.yaml`:

```yaml
plugins:
  flutter_layered_architecture_lint:
    path: packages/lint
```

Requires Dart 3.14+ (Flutter 3.50+). After changing `plugins:`, restart the Dart Analysis Server.

## Suppress

```dart
// ignore: flutter_layered_architecture_lint/stateful_immutable
```
