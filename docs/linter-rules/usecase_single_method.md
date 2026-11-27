# usecase_single_method

`@usecase` types must not declare more than one public instance method.

## Details

DO keep `@usecase` types to at most one public instance method. A Usecase is one operation; split into multiple Usecase types when you need more than one public entry point.

Private methods (`_`-prefixed) are not counted. Severity is WARNING.

Related annotation: `@usecase`.

BAD:

```dart
@usecase
abstract interface class TodoUsecase {
  Future<Todo> add(AddTodoRequest request);
  Future<void> delete(String id);
}
```

GOOD:

```dart
@usecase
abstract interface class AddTodoUsecase {
  const AddTodoUsecase();

  Future<Todo> execute(AddTodoRequest request);
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
// ignore: flutter_layered_architecture_lint/usecase_single_method
```
