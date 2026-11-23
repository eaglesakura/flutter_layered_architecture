import 'package:screen_feature_todo_list/src/viewmodel/state/todo_list_screen_state.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_todo/usecase_todo.dart';

/// Adds a todo from the draft title and refreshes the list.
final class OnAddTodoDelegate {
  final MutableStateStream<TodoListScreenState> _state;
  final AddTodoUsecase _addTodoUsecase;
  final ListTodosUsecase _listTodosUsecase;

  /// Creates an [OnAddTodoDelegate].
  const OnAddTodoDelegate({
    required MutableStateStream<TodoListScreenState> state,
    required AddTodoUsecase addTodoUsecase,
    required ListTodosUsecase listTodosUsecase,
  }) : _state = state,
       _addTodoUsecase = addTodoUsecase,
       _listTodosUsecase = listTodosUsecase;

  /// Executes the add action.
  Future<void> execute() async {
    final title = _state.state.draftTitle;
    if (title.trim().isEmpty) {
      return;
    }

    await _addTodoUsecase.execute(AddTodoRequest(title: title));
    final todos = await _listTodosUsecase.execute(const ListTodosRequest());
    await _state.updateWithLock((current, emitter) {
      return emitter.emit(
        current.copyWith(todos: todos, draftTitle: ''),
      );
    });
  }
}
