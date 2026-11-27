# usecase_method_signature

`@usecase` methods must have at least one parameter and a non-void return type.

## Details

DO give the single public instance method on an `@usecase` type at least one parameter and a non-void return type. Prefer an explicit request type for input and a domain result type for output.

This rule runs only when there is exactly one public instance method. Two or more public methods are covered by `usecase_single_method`. Severity is WARNING.

Related annotation: `@usecase`.

BAD:

```dart
@usecase
abstract interface class Bad {
  const Bad();

  void execute() {}
}
```

GOOD:

```dart
@usecase
abstract interface class ListTodosUsecase {
  const ListTodosUsecase();

  Future<List<Todo>> execute(ListTodosRequest request);
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
// ignore: flutter_layered_architecture_lint/usecase_method_signature
```
