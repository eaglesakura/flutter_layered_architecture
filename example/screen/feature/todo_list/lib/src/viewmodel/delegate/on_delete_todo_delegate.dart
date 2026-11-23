import 'package:screen_feature_todo_list/src/viewmodel/state/todo_list_screen_state.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_todo/usecase_todo.dart';

/// Deletes a todo and refreshes the list.
final class OnDeleteTodoDelegate {
  final MutableStateStream<TodoListScreenState> _state;
  final DeleteTodoUsecase _deleteTodoUsecase;
  final ListTodosUsecase _listTodosUsecase;

  /// Creates an [OnDeleteTodoDelegate].
  const OnDeleteTodoDelegate({
    required MutableStateStream<TodoListScreenState> state,
    required DeleteTodoUsecase deleteTodoUsecase,
    required ListTodosUsecase listTodosUsecase,
  }) : _state = state,
       _deleteTodoUsecase = deleteTodoUsecase,
       _listTodosUsecase = listTodosUsecase;

  /// Executes the delete action for [id].
  Future<void> execute(String id) async {
    await _deleteTodoUsecase.execute(DeleteTodoRequest(id: id));
    final todos = await _listTodosUsecase.execute();
    await _state.updateWithLock((current, emitter) {
      return emitter.emit(current.copyWith(todos: todos));
    });
  }
}
