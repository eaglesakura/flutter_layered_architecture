import 'package:domain_todo/domain_todo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lists all todo items.
abstract interface class ListTodosUsecase {
  /// Provides [ListTodosUsecase]. Must be overridden by an implementation package.
  static final provider = Provider<ListTodosUsecase>(
    (ref) => throw UnimplementedError('ListTodosUsecase is not bound'),
  );

  /// Loads the current todo list.
  Future<List<Todo>> execute();
}
