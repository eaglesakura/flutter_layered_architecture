import 'package:domain_todo/domain_todo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Persistence boundary for todo items (data layer).
abstract interface class TodoRepository {
  /// Provides [TodoRepository]. Must be overridden by an implementation package.
  static final provider = Provider<TodoRepository>(
    (ref) => throw UnimplementedError('TodoRepository is not bound'),
  );

  /// Returns all todo items in stable order (newest first).
  Future<List<Todo>> list();

  /// Inserts [todo] and returns the stored entity.
  Future<Todo> add(Todo todo);

  /// Replaces the item with the same [Todo.id].
  Future<Todo> update(Todo todo);

  /// Removes the item identified by [id].
  Future<void> delete(String id);
}
