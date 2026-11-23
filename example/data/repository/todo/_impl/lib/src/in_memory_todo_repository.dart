import 'package:data_repository_todo/data_repository_todo.dart';
import 'package:data_repository_todo_impl/src/in_memory_todo_repository_state.dart';
import 'package:domain_todo/domain_todo.dart';
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_stream/state_stream.dart';

/// In-memory [TodoRepository] for the sample app (Web / demo).
@stateful
final class InMemoryTodoRepository implements TodoRepository {
  /// Provides [InMemoryTodoRepository].
  static final provider = Provider<InMemoryTodoRepository>(
    (ref) {
      final result = InMemoryTodoRepository(
        state: MutableStateStream(const InMemoryTodoRepositoryState()),
      );
      ref.onDispose(result._close);
      return result;
    },
  );

  /// Repository state stream.
  final MutableStateStream<InMemoryTodoRepositoryState> state;

  /// Creates an [InMemoryTodoRepository].
  const InMemoryTodoRepository({
    required this.state,
  });

  @override
  Future<Todo> add(Todo todo) {
    return state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(items: [todo, ...current.items]),
      );
      return todo;
    });
  }

  @override
  Future<void> delete(String id) {
    return state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          items: [
            for (final item in current.items)
              if (item.id != id) item,
          ],
        ),
      );
    });
  }

  @override
  Future<List<Todo>> list() async {
    return List<Todo>.unmodifiable(state.state.items);
  }

  @override
  Future<Todo> update(Todo todo) {
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

  Future<void> _close() => state.close();
}
