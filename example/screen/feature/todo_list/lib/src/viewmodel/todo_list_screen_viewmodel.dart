import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart'
    hide state;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:screen_feature_todo_list/src/viewmodel/delegate/on_add_todo_delegate.dart';
import 'package:screen_feature_todo_list/src/viewmodel/delegate/on_delete_todo_delegate.dart';
import 'package:screen_feature_todo_list/src/viewmodel/delegate/on_initialize_delegate.dart';
import 'package:screen_feature_todo_list/src/viewmodel/delegate/on_toggle_todo_delegate.dart';
import 'package:screen_feature_todo_list/src/viewmodel/delegate/on_update_draft_title_delegate.dart';
import 'package:screen_feature_todo_list/src/viewmodel/delegate/todo_list_screen_state_to_entity_delegate.dart';
import 'package:screen_feature_todo_list/src/viewmodel/entity/todo_list_screen_entity.dart';
import 'package:screen_feature_todo_list/src/viewmodel/state/todo_list_screen_state.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_todo/usecase_todo.dart';

part 'todo_list_screen_viewmodel.action.dart';

/// ViewModel for the todo list screen.
@internal
@viewModel
final class TodoListScreenViewModel {
  /// Provides [TodoListScreenViewModel] with autoDispose lifecycle.
  static final provider = Provider.autoDispose<TodoListScreenViewModel>(
    (ref) {
      final listTodosUsecase = ref.watch(ListTodosUsecase.provider);
      final addTodoUsecase = ref.watch(AddTodoUsecase.provider);
      final toggleTodoUsecase = ref.watch(ToggleTodoUsecase.provider);
      final deleteTodoUsecase = ref.watch(DeleteTodoUsecase.provider);

      final result = TodoListScreenViewModel._(
        state: MutableStateStream(
          const TodoListScreenState(
            isLoading: true,
            todos: [],
            draftTitle: '',
          ),
        ),
        listTodosUsecase: listTodosUsecase,
        addTodoUsecase: addTodoUsecase,
        toggleTodoUsecase: toggleTodoUsecase,
        deleteTodoUsecase: deleteTodoUsecase,
        stateToEntityDelegate: const TodoListScreenStateToEntityDelegate(),
      );
      ref.onDispose(() {
        result._close();
      });
      return result;
    },
    dependencies: [
      ListTodosUsecase.provider,
      AddTodoUsecase.provider,
      ToggleTodoUsecase.provider,
      DeleteTodoUsecase.provider,
    ],
  );

  /// Screen state stream.
  @visibleForTesting
  final MutableStateStream<TodoListScreenState> state;

  /// Lists todo items.
  @visibleForTesting
  final ListTodosUsecase listTodosUsecase;

  /// Adds a todo item.
  @visibleForTesting
  final AddTodoUsecase addTodoUsecase;

  /// Toggles todo completion.
  @visibleForTesting
  final ToggleTodoUsecase toggleTodoUsecase;

  /// Deletes a todo item.
  @visibleForTesting
  final DeleteTodoUsecase deleteTodoUsecase;

  /// State to entity mapper.
  @visibleForTesting
  final TodoListScreenStateToEntityDelegate stateToEntityDelegate;

  const TodoListScreenViewModel._({
    required this.state,
    required this.listTodosUsecase,
    required this.addTodoUsecase,
    required this.toggleTodoUsecase,
    required this.deleteTodoUsecase,
    required this.stateToEntityDelegate,
  });

  /// Display entity derived from [state].
  StateStream<TodoListScreenEntity> get entity =>
      state.map(stateToEntityDelegate.execute);

  Future<void> _close() => state.close();
}
