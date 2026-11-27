# viewmodel_on_method_names

`@viewModel` instance and extension methods must be named `on...` (`close` / `_close` excepted).

## Details

DO name instance methods and extension methods on `@viewModel` types with an `on` prefix (for example `onAddTodo`, `onInitialize`). Align names with screen events such as taps. Getters and setters are out of scope. `close` and `_close` are allowed exceptions for stream disposal.

Severity is WARNING.

Related annotation: `@viewModel`. Companion rule: `stateful_methods_use_delegate` (actions should call `@delegate.execute`).

BAD:

```dart
extension on TodoListScreenViewModel {
  Future<void> addTodo() async {}
}
```

GOOD:

```dart
@internal
@viewModel
final class TodoListScreenViewModel {
  Future<void> _close() => state.close();
}

extension TodoListScreenViewModelActions on TodoListScreenViewModel {
  Future<void> onAddTodo() {
    return OnAddTodoDelegate(
      state: state,
      addTodoUsecase: addTodoUsecase,
    ).execute();
  }
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
// ignore: flutter_layered_architecture_lint/viewmodel_on_method_names
```
