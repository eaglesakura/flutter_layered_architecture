import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:screen_feature_todo_list/src/viewmodel/entity/todo_list_item_entity.dart';

export 'package:screen_feature_todo_list/src/viewmodel/entity/todo_list_item_entity.dart';

part 'todo_list_screen_entity.freezed.dart';

/// Display model for the todo list screen.
@internal
@freezed
abstract class TodoListScreenEntity with _$TodoListScreenEntity {
  /// Creates a [TodoListScreenEntity].
  const factory TodoListScreenEntity({
    /// Whether a loading indicator should be shown.
    required bool isLoading,

    /// Rows to render.
    required List<TodoListItemEntity> items,

    /// Current draft title for the input field.
    required String draftTitle,

    /// Whether the add button should be enabled.
    required bool canAdd,
  }) = _TodoListScreenEntity;
}
