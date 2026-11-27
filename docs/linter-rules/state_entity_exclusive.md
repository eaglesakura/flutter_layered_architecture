# state_entity_exclusive

Types must not be annotated with both `@state` and `@entity`.

## Details

DO NOT put both `@state` and `@entity` on the same type; use exactly one. This keeps State and Entity as distinct types. This is gate A: structure of the annotated type itself. Severity: WARNING.

Related annotations: `@state`, `@entity`.

BAD:

```dart
@internal
@state
@entity
@freezed
abstract class Both with _$Both {
  const factory Both({required int value}) = _Both;
}
```

GOOD:

```dart
@internal
@state
@freezed
abstract class TodoListScreenState with _$TodoListScreenState {
  const factory TodoListScreenState({
    required bool isLoading,
    required List<Todo> todos,
    required String draftTitle,
  }) = _TodoListScreenState;
}

@internal
@entity
@freezed
abstract class TodoListScreenEntity with _$TodoListScreenEntity {
  const factory TodoListScreenEntity({
    required bool isLoading,
    required List<Todo> todos,
    required String draftTitle,
  }) = _TodoListScreenEntity;
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
// ignore: flutter_layered_architecture_lint/state_entity_exclusive
```
