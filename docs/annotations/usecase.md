# @usecase

Marks a Usecase type in Flutter Layered Architecture so `flutter_layered_architecture_lint` can validate its structure.

## Details

DO attach `@usecase` to a Usecase interface (and, when needed, its implementation). A Usecase represents one operation. Public instance methods must be at most one (two or more are WARNING). Prefer a method named `execute` with a non-void return and at least one parameter. Fields must be `final`/`const`, and a `const` constructor is required.

Severity of related lint checks: WARNING.

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
abstract interface class ListTodosUsecase {
  const ListTodosUsecase();

  Future<List<Todo>> execute(ListTodosRequest request);
}
```

## Usage

Import:

```dart
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
```

Attach to: type (for example `abstract interface class` or `class`). Do not attach to a barrel `library`.

## Related linter rules

* [usecase_single_method](../linter-rules/usecase_single_method.md)
* [usecase_method_signature](../linter-rules/usecase_method_signature.md)
* [usecase_immutable](../linter-rules/usecase_immutable.md)
