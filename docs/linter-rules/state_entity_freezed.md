# state_entity_freezed

`@state` / `@entity` types must also be annotated with `@freezed` or `@Freezed`.

## Details

DO annotate every `@state` / `@entity` type with `@freezed` or `@Freezed()`. This is gate A: structure of the annotated type itself. Severity: WARNING.

Related annotations: `@state`, `@entity`.

BAD:

```dart
@state
final class PlainState {}
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
// ignore: flutter_layered_architecture_lint/state_entity_freezed
```
