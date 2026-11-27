# delegate_immutable

`@delegate` types must have only final fields and at least one const constructor.

## Details

DO make every field on an `@delegate` type `final` or `const`, and declare at least one `const` constructor. Keep dependencies and state references final so the Delegate can be assembled with `const`.

Severity is WARNING.

Related annotations: `@delegate`, `@internal`.

BAD:

```dart
@internal
@delegate
final class Bad {
  Bad(this.state);
  MutableStateStream<TodoListScreenState> state;

  Future<void> execute() async {}
}
```

GOOD:

```dart
@internal
@delegate
final class OnInitializeDelegate {
  const OnInitializeDelegate({
    required this.state,
    required this.listTodosUsecase,
  });

  final MutableStateStream<TodoListScreenState> state;
  final ListTodosUsecase listTodosUsecase;

  Future<void> execute() async {
    // ...
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
// ignore: flutter_layered_architecture_lint/delegate_immutable
```
