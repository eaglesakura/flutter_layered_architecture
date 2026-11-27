# delegate_execute_method

`@delegate` types must declare exactly one instance method named `execute`.

## Details

DO declare exactly one instance method on an `@delegate` type, and name it `execute`. Parameter lists and return types are unrestricted. Delegate is a single processing unit whose entry point is always `execute`.

Severity is WARNING.

Related annotations: `@delegate`, `@internal`.

BAD:

```dart
@internal
@delegate
final class Bad {
  const Bad();

  Future<void> run() async {}
}
```

GOOD:

```dart
@internal
@delegate
final class OnAddTodoDelegate {
  const OnAddTodoDelegate({required this.state});

  final MutableStateStream<TodoListScreenState> state;

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
// ignore: flutter_layered_architecture_lint/delegate_execute_method
```
