# delegate_no_nested_delegate

`@delegate` types must not accept or instantiate other `@delegate` types.

## Details

DO NOT take another `@delegate` type as a constructor parameter, and DO NOT construct another `@delegate` type inside a `@delegate` class. Nesting Delegates complicates the dependency graph; keep shared work in Usecase or helpers, and keep each Delegate as one screen action unit.

`@usecase` dependencies may still be injected via the constructor. Severity is WARNING.

Related annotation: `@delegate`.

BAD:

```dart
@internal
@delegate
final class Outer {
  const Outer({required this.inner});

  final OtherDelegate inner;

  Future<void> execute() async {}
}
```

GOOD:

```dart
@internal
@delegate
final class OnAddTodoDelegate {
  const OnAddTodoDelegate({required this.addTodoUsecase});

  final AddTodoUsecase addTodoUsecase;

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
// ignore: flutter_layered_architecture_lint/delegate_no_nested_delegate
```
