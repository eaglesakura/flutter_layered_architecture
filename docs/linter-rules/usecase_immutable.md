# usecase_immutable

`@usecase` types must have only final fields and at least one const constructor.

## Details

DO make every field on an `@usecase` type `final` or `const`, and declare at least one `const` constructor. Inject dependencies through the constructor so the type stays immutable and easy to construct in tests.

Severity is WARNING.

Related annotation: `@usecase`.

BAD:

```dart
@usecase
final class Bad {
  Bad(this.repository);
  TodoRepository repository;

  Future<Todo> execute(AddTodoRequest request) => repository.add(request);
}
```

GOOD:

```dart
@usecase
final class AddTodoUsecaseImpl {
  const AddTodoUsecaseImpl({required this.repository});

  final TodoRepository repository;

  Future<Todo> execute(AddTodoRequest request) => repository.add(request);
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
// ignore: flutter_layered_architecture_lint/usecase_immutable
```
