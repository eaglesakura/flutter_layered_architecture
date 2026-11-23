import 'package:screen_feature_todo_list/src/viewmodel/entity/todo_list_screen_entity.dart';
import 'package:screen_feature_todo_list/src/viewmodel/state/todo_list_screen_state.dart';

/// Converts [TodoListScreenState] into [TodoListScreenEntity].
final class TodoListScreenStateToEntityDelegate {
  /// Creates a [TodoListScreenStateToEntityDelegate].
  const TodoListScreenStateToEntityDelegate();

  /// Maps [state] to a display entity.
  TodoListScreenEntity execute(TodoListScreenState state) {
    return TodoListScreenEntity(
      isLoading: state.isLoading,
      draftTitle: state.draftTitle,
      canAdd: state.draftTitle.trim().isNotEmpty,
      items: [
        for (final todo in state.todos)
          TodoListItemEntity(
            id: todo.id,
            title: todo.title,
            isCompleted: todo.isCompleted,
          ),
      ],
    );
  }
}
