# delegate_no_usecase_instantiation

`@delegate` types must not instantiate `@usecase` types; inject them via the constructor instead.

## Details

DO inject `@usecase` dependencies through the constructor. DO NOT construct `@usecase` types inside a `@delegate` class body. Keeping creation outside the Delegate makes substitution in tests straightforward.

Severity is WARNING.

Related annotations: `@delegate`, `@usecase`.

BAD:

```dart
@internal
@delegate
final class Bad {
  const Bad();

  Future<void> execute() async {
    await AddTodoUsecaseImpl().execute(request);
  }
}
```

GOOD:

```dart
@internal
@delegate
final class OnAddTodoDelegate {
  const OnAddTodoDelegate({required this.addTodoUsecase});

  final AddTodoUsecase addTodoUsecase;

  Future<void> execute() => addTodoUsecase.execute(request);
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
// ignore: flutter_layered_architecture_lint/delegate_no_usecase_instantiation
```
