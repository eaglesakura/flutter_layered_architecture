# one_public_type_per_file

A file must declare at most one public named type (`class` / `enum` / `mixin` / named `extension` / `extension type`).

## Details

DO place at most one public named type in each Dart file. Split files or mark helpers as private (`_`-prefixed) when more than one type is needed.

Private types and `typedef`s are ignored. Files that are `part of` another library and paths under `test/` are skipped. Zero public types is allowed. Severity is WARNING.

No related annotation (file layout rule).

BAD:

```dart
// models.dart
final class AddTodoRequest {
  const AddTodoRequest({required this.title});
  final String title;
}

final class ListTodosRequest {
  const ListTodosRequest();
}
```

GOOD:

```dart
// add_todo_request.dart
final class AddTodoRequest {
  const AddTodoRequest({required this.title});
  final String title;
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
// ignore: flutter_layered_architecture_lint/one_public_type_per_file
```
