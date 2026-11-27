# viewmodel_has_entity_getter

`@viewModel` types must declare a `StateStream<T> get entity` getter.

## Details

DO declare `StateStream<T> get entity` on every `@viewModel` type. Views should watch the entity stream, not the internal `MutableStateStream` state. Map state to entity with `state.map` and a `@delegate` when needed.

Severity is WARNING.

Related annotation: `@viewModel`. Companion rules: `viewmodel_entity_annotated`, `viewmodel_entity_differs_from_state`. `@viewModel` also inherits `@stateful` rules.

BAD:

```dart
@internal
@viewModel
final class Bad {
  const Bad({required this.state});

  final MutableStateStream<TodoListScreenState> state;
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
// ignore: flutter_layered_architecture_lint/viewmodel_has_entity_getter
```
