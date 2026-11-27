# viewmodel_entity_annotated

The `StateStream<T>` type argument of `entity` on `@viewModel` must be a class annotated with `@entity`.

## Details

DO annotate the model type `T` in `StateStream<T> get entity` with `@entity`. This is gate B: the rule checks only that `@entity` is present on the root type argument. Freezed shape, `@internal`, and factory constraints are enforced by gate A (`state_entity_*` rules) on the `@entity` type itself.

Severity is WARNING.

Related annotations: `@viewModel`, `@entity`. Companion rules: `viewmodel_has_entity_getter`, `stateful_mutable_state_stream_state`. Keep entity and state as distinct types (`viewmodel_entity_differs_from_state`).

BAD:

```dart
@freezed
abstract class TodoListScreenEntity with _$TodoListScreenEntity {
  const factory TodoListScreenEntity({required bool isLoading}) =
      _TodoListScreenEntity;
}

@internal
@viewModel
final class Bad {
  StateStream<TodoListScreenEntity> get entity => throw UnimplementedError();
}
```

GOOD:

```dart
@internal
@entity
@freezed
abstract class TodoListScreenEntity with _$TodoListScreenEntity {
  const factory TodoListScreenEntity({
    required bool isLoading,
    required List<TodoListItemEntity> items,
    required String draftTitle,
    required bool canAdd,
  }) = _TodoListScreenEntity;
}

StateStream<TodoListScreenEntity> get entity =>
    state.map(stateToEntityDelegate.execute);
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
// ignore: flutter_layered_architecture_lint/viewmodel_entity_annotated
```
