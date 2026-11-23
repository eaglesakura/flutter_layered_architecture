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
