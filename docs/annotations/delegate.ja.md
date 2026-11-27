# @delegate

ViewModel 等から切り出した単一処理クラスを示し、`flutter_layered_architecture_lint` が構造を検証できるようにするアノテーションである。

## Details

DO `@stateful` / `@viewModel` などから切り出した単一処理クラスに `@delegate` を付与する。併記として `@internal`（`package:meta`）が必須である。インスタンスメソッドはちょうど 1 つで名前は `execute`、フィールドは `final`/`const`、コンストラクタは `const` とする。別の `@delegate` を引数や内部生成で入れ子にしてはならない。`@usecase` 付き型はコンストラクタで受け取り、内部で生成してはならない。

関連 lint の Severity: WARNING。

BAD:

```dart
@delegate
final class Bad {
  Future<void> run() async {}
}
```

GOOD:

```dart
@internal
@delegate
final class OnAddTodoDelegate {
  const OnAddTodoDelegate({
    required this.state,
    required this.addTodoUsecase,
  });

  final MutableStateStream<TodoListScreenState> state;
  final AddTodoUsecase addTodoUsecase;

  Future<void> execute() async {
    await addTodoUsecase.execute(...);
  }
}
```

## Usage

Import:

```dart
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
```

`@internal` 用に `package:meta/meta.dart` も import する。

付与先: 型（`final class` など）。バレル `library` には付けない。

## Related linter rules

* [delegate_execute_method](../linter-rules/delegate_execute_method.ja.md)
* [delegate_immutable](../linter-rules/delegate_immutable.ja.md)
* [delegate_internal](../linter-rules/delegate_internal.ja.md)
* [delegate_no_nested_delegate](../linter-rules/delegate_no_nested_delegate.ja.md)
* [delegate_no_usecase_instantiation](../linter-rules/delegate_no_usecase_instantiation.ja.md)
