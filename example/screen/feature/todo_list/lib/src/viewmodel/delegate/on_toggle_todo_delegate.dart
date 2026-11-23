import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:meta/meta.dart';
import 'package:screen_feature_todo_list/src/viewmodel/state/todo_list_screen_state.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_todo/usecase_todo.dart';

/// Toggles completion for a todo and refreshes the list.
@internal
@delegate
final class OnToggleTodoDelegate {
  final MutableStateStream<TodoListScreenState> _state;
  final ToggleTodoUsecase _toggleTodoUsecase;
  final ListTodosUsecase _listTodosUsecase;

  /// Creates an [OnToggleTodoDelegate].
  const OnToggleTodoDelegate({
    required MutableStateStream<TodoListScreenState> state,
    required ToggleTodoUsecase toggleTodoUsecase,
    required ListTodosUsecase listTodosUsecase,
  }) : _state = state,
       _toggleTodoUsecase = toggleTodoUsecase,
       _listTodosUsecase = listTodosUsecase;

  /// Executes the toggle action for [id].
  Future<void> execute(String id) async {
    await _toggleTodoUsecase.execute(ToggleTodoRequest(id: id));
    final todos = await _listTodosUsecase.execute(const ListTodosRequest());
    await _state.updateWithLock((current, emitter) {
      return emitter.emit(current.copyWith(todos: todos));
    });
  }
}
