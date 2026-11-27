# viewmodel_entity_differs_from_state

The `entity` model type on `@viewModel` must differ from the `MutableStateStream` state model type.

## Details

DO use a distinct model type for `entity` versus the primary `MutableStateStream<T>` state field. Keep state domain-oriented and entity display-oriented so the View does not couple to internal state.

Severity is WARNING.

Related annotation: `@viewModel`. Companion rules: `viewmodel_has_entity_getter`, `viewmodel_entity_annotated`. State models use `@state`; entity models use `@entity`.

BAD:

```dart
@internal
@viewModel
final class Bad {
  const Bad({required this.state});

  final MutableStateStream<TodoListScreenState> state;

  StateStream<TodoListScreenState> get entity => state;
}
```

GOOD:

```dart
@internal
@viewModel
final class TodoListScreenViewModel {
  const TodoListScreenViewModel({
    required this.state,
    required this.stateToEntityDelegate,
  });

  final MutableStateStream<TodoListScreenState> state;
  final TodoListScreenStateToEntityDelegate stateToEntityDelegate;

  StateStream<TodoListScreenEntity> get entity =>
      state.map(stateToEntityDelegate.execute);
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
// ignore: flutter_layered_architecture_lint/viewmodel_entity_differs_from_state
```
