# @usecase

Flutter Layered Architecture における Usecase 型を示し、`flutter_layered_architecture_lint` が構造を検証できるようにするアノテーションである。

## Details

DO Usecase の interface（および必要に応じて実装）に `@usecase` を付与する。Usecase は 1 操作を表す。public インスタンスメソッドは高々 1 つとする（2 つ以上は WARNING）。メソッド名は原則 `execute` とし、引数あり・非 void とする。フィールドは `final`/`const`、コンストラクタは `const` とする。

関連 lint の Severity: WARNING。

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

付与先: 型（`abstract interface class` / `class` など）。バレル `library` には付けない。

## Related linter rules

* [usecase_single_method](../linter-rules/usecase_single_method.ja.md)
* [usecase_method_signature](../linter-rules/usecase_method_signature.ja.md)
* [usecase_immutable](../linter-rules/usecase_immutable.ja.md)
