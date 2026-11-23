/// Display model for a single todo row.
final class TodoListItemEntity {
  /// Identifier used for row actions.
  final String id;

  /// Title shown in the list.
  final String title;

  /// Whether the checkbox is checked.
  final bool isCompleted;

  /// Creates a [TodoListItemEntity].
  const TodoListItemEntity({
    required this.id,
    required this.title,
    required this.isCompleted,
  });
}

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
