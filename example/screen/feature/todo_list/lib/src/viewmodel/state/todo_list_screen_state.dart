import 'package:domain_todo/domain_todo.dart';

/// Mutable screen state for the todo list screen.
final class TodoListScreenState {
  /// Whether the first load is in progress.
  final bool isLoading;

  /// Current todo items.
  final List<Todo> todos;

  /// Draft title in the input field.
  final String draftTitle;

  /// Creates a [TodoListScreenState].
  const TodoListScreenState({
    required this.isLoading,
    required this.todos,
    required this.draftTitle,
  });

  /// Initial loading state.
  factory TodoListScreenState.initial() {
    return const TodoListScreenState(
      isLoading: true,
      todos: [],
      draftTitle: '',
    );
  }

  /// Returns a copy with selected fields replaced.
  TodoListScreenState copyWith({
    bool? isLoading,
    List<Todo>? todos,
    String? draftTitle,
  }) {
    return TodoListScreenState(
      isLoading: isLoading ?? this.isLoading,
      todos: todos ?? this.todos,
      draftTitle: draftTitle ?? this.draftTitle,
    );
  }
}
