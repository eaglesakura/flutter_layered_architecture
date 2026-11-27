# @viewModel

Marks a screen-facing ViewModel type. It inherits `@stateful` constraints and adds presentation (`entity`) and method-naming rules for `flutter_layered_architecture_lint`.

## Details

DO attach `@viewModel` to Screen-layer ViewModels. You do not need to also write `@stateful`; `@viewModel` alone is enough for stateful rules. Companion `@internal` (`package:meta`) is required.

Inherited `@stateful` constraints:

* All fields `final`/`const`, `const` constructor
* Own `MutableStateStream<T>` where root `T` carries `@state`
* Call `MutableStateStream.close()` on some path
* Delegate instance/extension method bodies to `@delegate.execute` (`close` / `_close` excepted)

Additional ViewModel rules:

* Declare `StateStream<T> get entity`; root `T` must carry `@entity` (structure via gate A)
* The `entity` model type must differ from the `MutableStateStream` state model type
* Instance and extension methods (except `close` / `_close`) must start with `on`

Severity of related lint checks: WARNING.

BAD:

```dart
@viewModel
final class BadViewModel {
  Future<void> addTodo() async {}
}
```

GOOD:

```dart
@internal
@viewModel
final class TodoListScreenViewModel {
  const TodoListScreenViewModel({
    required this.state,
    required this.stateToEntityDelegate,
  });

  final MutableStateStream<TodoListScreenState> state;
  final TodoListScreenStateToEntityDelegate stateToEntityDelegate;

  StateStream<TodoListScreenEntity> get entity =>
      state.map(stateToEntityDelegate.execute);

  Future<void> _close() => state.close();
}

extension TodoListScreenViewModelActions on TodoListScreenViewModel {
  Future<void> onAddTodo() {
    return OnAddTodoDelegate(state: state, ...).execute();
  }
}
```

## Usage

Import:

```dart
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
```

Also import `package:meta/meta.dart` for `@internal`.

Attach to: type. Do not attach to a barrel `library`.

## Related linter rules

* [viewmodel_internal](../linter-rules/viewmodel_internal.md)
* [viewmodel_has_entity_getter](../linter-rules/viewmodel_has_entity_getter.md)
* [viewmodel_entity_annotated](../linter-rules/viewmodel_entity_annotated.md)
* [viewmodel_entity_differs_from_state](../linter-rules/viewmodel_entity_differs_from_state.md)
* [viewmodel_on_method_names](../linter-rules/viewmodel_on_method_names.md)
* [stateful_immutable](../linter-rules/stateful_immutable.md)
* [stateful_has_mutable_state_stream](../linter-rules/stateful_has_mutable_state_stream.md)
* [stateful_closes_mutable_state_stream](../linter-rules/stateful_closes_mutable_state_stream.md)
* [stateful_mutable_state_stream_state](../linter-rules/stateful_mutable_state_stream_state.md)
* [stateful_methods_use_delegate](../linter-rules/stateful_methods_use_delegate.md)
