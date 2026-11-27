# @stateful

Marks a state-holding type that owns a `MutableStateStream` so `flutter_layered_architecture_lint` can validate its structure.

## Details

DO attach `@stateful` to types that hold `MutableStateStream` and act as a state update core (including non-screen types such as an in-memory Repository). Fields must be `final`/`const`, and a `const` constructor is required. The type must own a `MutableStateStream<T>` field and call `MutableStateStream.close()` on some path (`close` / `_close` are allowed exceptions for that call). The root type argument `T` must carry `@state` (Freezed and other structure rules are enforced by gate A on the `@state` type). Instance and extension methods must delegate to `@delegate.execute` (`close` / `_close` that only close the stream are excepted).

For screen ViewModels, prefer `@viewModel` instead; it inherits these constraints.

Severity of related lint checks: WARNING.

BAD:

```dart
@stateful
final class Bad {
  Bad();
  var count = 0;

  void increment() {
    count++;
  }
}
```

GOOD:

```dart
@stateful
final class InMemoryTodoRepository implements TodoRepository {
  const InMemoryTodoRepository({required this.state});

  final MutableStateStream<InMemoryTodoRepositoryState> state;

  @override
  Future<Todo> add(Todo todo) {
    return AddTodoInMemoryDelegate(state: state).execute(todo);
  }

  Future<void> _close() => state.close();
}
```

## Usage

Import:

```dart
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
```

Attach to: type. Do not attach to a barrel `library`.

## Related linter rules

* [stateful_immutable](../linter-rules/stateful_immutable.md)
* [stateful_has_mutable_state_stream](../linter-rules/stateful_has_mutable_state_stream.md)
* [stateful_closes_mutable_state_stream](../linter-rules/stateful_closes_mutable_state_stream.md)
* [stateful_mutable_state_stream_state](../linter-rules/stateful_mutable_state_stream_state.md)
* [stateful_methods_use_delegate](../linter-rules/stateful_methods_use_delegate.md)
