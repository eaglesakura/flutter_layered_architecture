import 'package:data_repository_todo/data_repository_todo.dart';
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
        items: MutableStateStream<List<Todo>>(const []),
      );
      ref.onDispose(result._close);
      return result;
    },
  );

  /// Stored todo items (newest first).
  final MutableStateStream<List<Todo>> items;

  /// Creates an [InMemoryTodoRepository].
  const InMemoryTodoRepository({
    required this.items,
  });

  @override
  Future<Todo> add(Todo todo) {
    return items.updateWithLock((current, emitter) async {
      await emitter.emit([todo, ...current]);
      return todo;
    });
  }

  @override
  Future<void> delete(String id) {
    return items.updateWithLock((current, emitter) async {
      await emitter.emit([
        for (final item in current)
          if (item.id != id) item,
      ]);
    });
  }

  @override
  Future<List<Todo>> list() async {
    return List<Todo>.unmodifiable(items.state);
  }

  @override
  Future<Todo> update(Todo todo) {
    return items.updateWithLock((current, emitter) async {
      final index = current.indexWhere((item) => item.id == todo.id);
      if (index < 0) {
        throw StateError('Todo not found: ${todo.id}');
      }
      final next = [...current];
      next[index] = todo;
      await emitter.emit(next);
      return todo;
    });
  }

  Future<void> _close() => items.close();
}
