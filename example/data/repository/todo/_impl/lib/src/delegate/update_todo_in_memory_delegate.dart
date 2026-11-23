import 'package:data_repository_todo_impl/src/in_memory_todo_repository_state.dart';
import 'package:domain_todo/domain_todo.dart';
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';

/// In-memory の Todo を更新する Delegate.
@internal
@delegate
final class UpdateTodoInMemoryDelegate {
  /// Repository state stream.
  final MutableStateStream<InMemoryTodoRepositoryState> state;

  /// Creates an [UpdateTodoInMemoryDelegate].
  const UpdateTodoInMemoryDelegate({
    required this.state,
  });

  /// [todo] と同 id の要素を置き換えて返す.
  Future<Todo> execute(Todo todo) {
    return state.updateWithLock((current, emitter) async {
      final index = current.items.indexWhere((item) => item.id == todo.id);
      if (index < 0) {
        throw StateError('Todo not found: ${todo.id}');
      }
      final next = [...current.items];
      next[index] = todo;
      await emitter.emit(current.copyWith(items: next));
      return todo;
    });
  }
}
