part of 'todo_list_screen_viewmodel.dart';

/// Widget-facing actions for [TodoListScreenViewModel].
extension TodoListScreenViewModelActions on TodoListScreenViewModel {
  /// Adds a todo from the draft title.
  Future<void> onAddTodo() {
    return OnAddTodoDelegate(
      state: state,
      addTodoUsecase: addTodoUsecase,
      listTodosUsecase: listTodosUsecase,
    ).execute();
  }

  /// Deletes the todo identified by [id].
  Future<void> onDeleteTodo(String id) {
    return OnDeleteTodoDelegate(
      state: state,
      deleteTodoUsecase: deleteTodoUsecase,
      listTodosUsecase: listTodosUsecase,
    ).execute(id);
  }

  /// Loads the initial todo list.
  Future<void> onInitialize() {
    return OnInitializeDelegate(
      state: state,
      listTodosUsecase: listTodosUsecase,
    ).execute();
  }

  /// Toggles completion for [id].
  Future<void> onToggleTodo(String id) {
    return OnToggleTodoDelegate(
      state: state,
      toggleTodoUsecase: toggleTodoUsecase,
      listTodosUsecase: listTodosUsecase,
    ).execute(id);
  }

  /// Updates the draft title field.
  Future<void> onUpdateDraftTitle(String title) {
    return OnUpdateDraftTitleDelegate(state: state).execute(title);
  }
}
