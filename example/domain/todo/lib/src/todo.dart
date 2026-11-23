/// A single todo item in the domain layer.
final class Todo {
  /// Unique identifier.
  final String id;

  /// Display title.
  final String title;

  /// Whether the item is completed.
  final bool isCompleted;

  /// Creates a [Todo].
  const Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  /// Returns a copy with selected fields replaced.
  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
