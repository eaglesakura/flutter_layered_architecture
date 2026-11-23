import 'package:data_repository_todo_impl/src/in_memory_todo_repository_state.dart';
import 'package:domain_todo/domain_todo.dart';
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';

/// In-memory へ Todo を追加する Delegate.
@internal
@delegate
final class AddTodoInMemoryDelegate {
  /// Repository state stream.
  final MutableStateStream<InMemoryTodoRepositoryState> state;

  /// Creates an [AddTodoInMemoryDelegate].
  const AddTodoInMemoryDelegate({
    required this.state,
  });

  /// [todo] を先頭に追加して返す.
  Future<Todo> execute(Todo todo) {
    return state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(items: [todo, ...current.items]),
      );
      return todo;
    });
  }
}
