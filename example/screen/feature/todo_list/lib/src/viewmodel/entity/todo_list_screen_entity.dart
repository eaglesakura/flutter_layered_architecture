import 'package:screen_feature_todo_list/src/viewmodel/entity/todo_list_item_entity.dart';

export 'package:screen_feature_todo_list/src/viewmodel/entity/todo_list_item_entity.dart';

/// Display model for the todo list screen.
final class TodoListScreenEntity {
  /// Whether a loading indicator should be shown.
  final bool isLoading;

  /// Rows to render.
  final List<TodoListItemEntity> items;

  /// Current draft title for the input field.
  final String draftTitle;

  /// Whether the add button should be enabled.
  final bool canAdd;

  /// Creates a [TodoListScreenEntity].
  const TodoListScreenEntity({
    required this.isLoading,
    required this.items,
    required this.draftTitle,
    required this.canAdd,
  });
}
