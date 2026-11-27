# @delegate

Marks a single-operation Delegate class extracted from a ViewModel or similar type so `flutter_layered_architecture_lint` can validate its structure.

## Details

DO attach `@delegate` to a class that owns one operation (typically called from `@stateful` / `@viewModel`). Companion `@internal` (`package:meta`) is required. The type must expose exactly one instance method named `execute`, keep fields `final`/`const`, and provide a `const` constructor. Do not nest another `@delegate` via constructor parameters or internal construction. Accept `@usecase` types via the constructor; do not instantiate them inside the Delegate.

Severity of related lint checks: WARNING.

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

Also import `package:meta/meta.dart` for `@internal`.

Attach to: type (for example `final class`). Do not attach to a barrel `library`.

## Related linter rules

* [delegate_execute_method](../linter-rules/delegate_execute_method.md)
* [delegate_immutable](../linter-rules/delegate_immutable.md)
* [delegate_internal](../linter-rules/delegate_internal.md)
* [delegate_no_nested_delegate](../linter-rules/delegate_no_nested_delegate.md)
* [delegate_no_usecase_instantiation](../linter-rules/delegate_no_usecase_instantiation.md)
