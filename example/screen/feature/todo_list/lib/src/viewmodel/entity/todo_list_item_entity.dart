import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_list_item_entity.freezed.dart';

/// Display model for a single todo row.
@internal
@freezed
abstract class TodoListItemEntity with _$TodoListItemEntity {
  /// Creates a [TodoListItemEntity].
  const factory TodoListItemEntity({
    /// Identifier used for row actions.
    required String id,

    /// Title shown in the list.
    required String title,

    /// Whether the checkbox is checked.
    required bool isCompleted,
  }) = _TodoListItemEntity;
}
