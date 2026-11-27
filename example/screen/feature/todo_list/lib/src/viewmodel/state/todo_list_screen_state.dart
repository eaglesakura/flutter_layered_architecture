import 'package:domain_todo/domain_todo.dart';
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'todo_list_screen_state.freezed.dart';

/// Mutable screen state for the todo list screen.
///
/// Example:
/// ```dart
/// const TodoListScreenState(
///   isLoading: true,
///   todos: [],
///   draftTitle: '',
/// );
/// ```
@internal
@state
@freezed
abstract class TodoListScreenState with _$TodoListScreenState {
  /// Creates a [TodoListScreenState].
  const factory TodoListScreenState({
    /// Whether the first load is in progress.
    required bool isLoading,

    required List<Todo> todos,

    /// Draft title in the input field.
    required String draftTitle,
  }) = _TodoListScreenState;
}
