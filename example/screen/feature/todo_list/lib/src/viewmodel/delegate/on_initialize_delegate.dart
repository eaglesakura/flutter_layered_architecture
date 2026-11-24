import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:meta/meta.dart';
import 'package:screen_feature_todo_list/src/viewmodel/state/todo_list_screen_state.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_todo/usecase_todo.dart';

/// Loads the initial todo list into the screen state stream.
@internal
@delegate
final class OnInitializeDelegate {
  final MutableStateStream<TodoListScreenState> _state;
  final ListTodosUsecase _listTodosUsecase;

  /// Creates an [OnInitializeDelegate].
  const OnInitializeDelegate({
    required this._state,
    required this._listTodosUsecase,
  });

  /// Executes the initialize action.
  Future<void> execute() async {
    await _state.updateWithLock((current, emitter) {
      return emitter.emit(current.copyWith(isLoading: true));
    });
    final todos = await _listTodosUsecase.execute(const ListTodosRequest());
    await _state.updateWithLock((current, emitter) {
      return emitter.emit(
        current.copyWith(isLoading: false, todos: todos),
      );
    });
  }
}
