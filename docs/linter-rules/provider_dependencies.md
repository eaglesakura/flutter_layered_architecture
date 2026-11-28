# provider_dependencies

List every `ref.watch(X)` argument from the create callback in `dependencies` with a literal source match.

## Details

DO include each watched reference in `dependencies: [...]` (`toSource().trim()` match).

DO NOT omit `dependencies`, use only `[]`, or drop some entries. Declarations with no `ref.watch` (IF stubs, `stateBy`-only, etc.) are skipped. Extra dependency entries are allowed. Severity is WARNING. Each missing watch reports one diagnostic.

BAD:

```dart
static final provider = Provider<AddTodoUsecaseImpl>(
  (ref) => AddTodoUsecaseImpl(ref.watch(TodoRepository.provider)),
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
// ignore: flutter_layered_architecture_lint/provider_dependencies
```