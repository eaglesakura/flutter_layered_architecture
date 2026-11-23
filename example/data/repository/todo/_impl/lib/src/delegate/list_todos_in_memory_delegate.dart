import 'package:data_repository_todo_impl/src/in_memory_todo_repository_state.dart';
import 'package:domain_todo/domain_todo.dart';
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';

/// In-memory の Todo 一覧を返す Delegate.
@internal
@delegate
final class ListTodosInMemoryDelegate {
  /// Repository state stream.
  final MutableStateStream<InMemoryTodoRepositoryState> state;

  /// Creates a [ListTodosInMemoryDelegate].
  const ListTodosInMemoryDelegate({
    required this.state,
  });

  /// 現在の Todo 一覧（変更不可）を返す.
  Future<List<Todo>> execute() async {
    return List<Todo>.unmodifiable(state.state.items);
  }
}
