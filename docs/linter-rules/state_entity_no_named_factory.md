# state_entity_no_named_factory

Named factories on `@state` / `@entity` types are discouraged; require all arguments at call sites.

## Details

DO NOT define named factories (for example `factory Foo.initial()`) on `@state` / `@entity` types. Call sites must pass every argument to the primary factory. This is gate A: structure of the annotated type itself. Severity: WARNING.

Related annotations: `@state`, `@entity`.

BAD:

```dart
@internal
@state
@freezed
abstract class Bad with _$Bad {
  const factory Bad({required int value}) = _Bad;

  factory Bad.zero() => const Bad(value: 0);
}
```

GOOD:

```dart
const TodoListScreenState(
  isLoading: true,
  todos: [],
  draftTitle: '',
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
// ignore: flutter_layered_architecture_lint/state_entity_no_named_factory
```
