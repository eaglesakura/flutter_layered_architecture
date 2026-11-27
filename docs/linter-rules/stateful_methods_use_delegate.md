# stateful_methods_use_delegate

`@stateful`/`@viewModel` instance methods must delegate to a `@delegate` execute method (`close`/`_close` that only closes `MutableStateStream` is allowed).

## Details

DO route business logic on `@stateful` / `@viewModel` instance methods (and extensions on those types) through a `@delegate` type's `execute` call. Methods named `close` / `_close` that only call `MutableStateStream.close()` are excepted. Also applies to `@viewModel` (inherits `@stateful`). Severity: WARNING.

Related annotations: `@stateful`, `@viewModel`, `@delegate`.

BAD:

```dart
@viewModel
final class Bad {
  Future<void> onAddTodo() async {
    await state.updateWithLock((current) async => current);
  }
}
```

GOOD:

```dart
@viewModel
final class TodoListScreenViewModel {
  Future<void> onAddTodo() => OnAddTodoDelegate(...).execute();
  Future<void> close() => state.close();
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
// ignore: flutter_layered_architecture_lint/stateful_methods_use_delegate
```
