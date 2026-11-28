# provider_ref_watch

Prefer `ref.watch` over `ref.read` in Provider create callbacks.

## Details

DO obtain dependencies with `ref.watch(...)` at the create callback surface.

DO NOT use `ref.read(...)` at that surface. Nested functions, Widget code, and non-Provider creation sites are out of scope. Declarations that end with `.stateBy` have no create callback and are skipped. Severity is WARNING.

BAD:

```dart
static final provider = Provider<AddTodoUsecaseImpl>(
  (ref) => AddTodoUsecaseImpl(ref.read(TodoRepository.provider)),
  dependencies: [TodoRepository.provider],
);
```

GOOD:

```dart
static final provider = Provider<AddTodoUsecaseImpl>(
  (ref) => AddTodoUsecaseImpl(ref.watch(TodoRepository.provider)),
  dependencies: [TodoRepository.provider],
);
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
// ignore: flutter_layered_architecture_lint/provider_ref_watch
```