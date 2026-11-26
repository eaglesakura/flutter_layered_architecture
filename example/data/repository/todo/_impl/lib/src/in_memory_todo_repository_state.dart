import 'package:domain_todo/domain_todo.dart';
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'in_memory_todo_repository_state.freezed.dart';

/// In-memory TodoRepository が保持する状態.
///
/// Example:
/// ```dart
/// const InMemoryTodoRepositoryState(items: []);
/// ```
@internal
@state
@freezed
abstract class InMemoryTodoRepositoryState with _$InMemoryTodoRepositoryState {
  /// [InMemoryTodoRepositoryState] を生成する.
  ///
  /// [items] は新しい順の Todo 一覧.
  const factory InMemoryTodoRepositoryState({
    required List<Todo> items,
  }) = _InMemoryTodoRepositoryState;
}
