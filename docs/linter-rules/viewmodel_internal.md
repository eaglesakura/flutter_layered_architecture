# viewmodel_internal

`@viewModel` types must also be annotated with `@internal`.

## Details

DO annotate every `@viewModel` type with `@internal` (`package:meta`). Treat the ViewModel as Screen-package implementation detail, not a public API.

Severity is WARNING.

Related annotation: `@viewModel`. `@viewModel` also inherits `@stateful` rules (`stateful_immutable`, `stateful_has_mutable_state_stream`, `stateful_closes_mutable_state_stream`, `stateful_mutable_state_stream_state`, `stateful_methods_use_delegate`).

BAD:

```dart
@viewModel
final class TodoListScreenViewModel {
  const TodoListScreenViewModel({required this.state});

  final MutableStateStream<TodoListScreenState> state;
}
```

GOOD:

```dart
@internal
@viewModel
final class TodoListScreenViewModel {
  const TodoListScreenViewModel({required this.state});

  final MutableStateStream<TodoListScreenState> state;
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
// ignore: flutter_layered_architecture_lint/viewmodel_internal
```
