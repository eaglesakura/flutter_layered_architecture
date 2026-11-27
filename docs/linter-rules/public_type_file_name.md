# public_type_file_name

The file name must be the `lower_snake_case` form of the single public type name.

For the `layered_architecture.yaml` schema including `keywords`, see [layered_architecture_yaml.md](../layered_architecture_yaml.md).

## Details

DO name the file after its only public named type, converted to `lower_snake_case`. When there are zero or two or more public types, this rule does not report (count violations are covered by `one_public_type_per_file`).

Optional keywords in the nearest `layered_architecture.yaml` can map CamelCase segments to file-name tokens:

```yaml
rules:
  public_type_file_name:
    keywords:
      UseCase: usecase
      ViewModel: viewmodel
```

With `UseCase: usecase`, type `AddTodoUseCase` expects `add_todo_usecase.dart` (without keywords it would be `add_todo_use_case.dart`). Keywords apply in YAML declaration order (earlier keys win on overlapping segments). Matching is case-sensitive (`UseCase` does not match type segment `Usecase`). Missing or empty `rules` / `keywords` keeps the default PascalCase→snake conversion.

Files that are `part of` another library and paths under `test/` are skipped. Severity is WARNING.

No related annotation (file layout rule).

BAD:

```dart
// usecase.dart
@usecase
abstract interface class AddTodoUsecase {
  const AddTodoUsecase();

  Future<Todo> execute(AddTodoRequest request);
}
```

GOOD:

```dart
// add_todo_usecase.dart
@usecase
abstract interface class AddTodoUsecase {
  const AddTodoUsecase();

  Future<Todo> execute(AddTodoRequest request);
}
```

With `keywords: UseCase: usecase`:

```dart
// add_todo_usecase.dart
@usecase
abstract interface class AddTodoUseCase {
  const AddTodoUseCase();

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
// ignore: flutter_layered_architecture_lint/public_type_file_name
```
