# state_entity_required_parameters

Primary data factory parameters on `@state` / `@entity` types must be required without `@Default` or default values.

## Details

DO make every parameter on the primary (unnamed) data factory of a `@state` / `@entity` type `required`. Do not use `@Default` or Dart default values. Each violating parameter is reported. This is gate A: structure of the annotated type itself. Severity: WARNING.

Related annotations: `@state`, `@entity`.

BAD:

```dart
@internal
@state
@freezed
abstract class Bad with _$Bad {
  const factory Bad({
    @Default(0) int value,
  }) = _Bad;
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
// ignore: flutter_layered_architecture_lint/state_entity_required_parameters
```
