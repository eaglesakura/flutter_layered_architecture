import 'package:data_repository_todo/data_repository_todo.dart';
import 'package:data_repository_todo_impl/src/delegate/add_todo_in_memory_delegate.dart';
import 'package:data_repository_todo_impl/src/delegate/delete_todo_in_memory_delegate.dart';
import 'package:data_repository_todo_impl/src/delegate/list_todos_in_memory_delegate.dart';
import 'package:data_repository_todo_impl/src/delegate/update_todo_in_memory_delegate.dart';
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
    return AddTodoInMemoryDelegate(state: state).execute(todo);
  }

  @override
  Future<void> delete(String id) {
    return DeleteTodoInMemoryDelegate(state: state).execute(id);
  }

  @override
  Future<List<Todo>> list() {
    return ListTodosInMemoryDelegate(state: state).execute();
  }

  @override
  Future<Todo> update(Todo todo) {
    return UpdateTodoInMemoryDelegate(state: state).execute(todo);
  }

  Future<void> _close() => state.close();
}
