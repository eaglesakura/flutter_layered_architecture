import 'package:domain_todo/domain_todo.dart';
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Request for [ListTodosUsecase].
final class ListTodosRequest {
  /// Creates a [ListTodosRequest].
  const ListTodosRequest();
}

/// Lists all todo items.
@usecase
abstract interface class ListTodosUsecase {
  /// Provides [ListTodosUsecase]. Must be overridden by an implementation package.
  static final provider = Provider<ListTodosUsecase>(
    (ref) => throw UnimplementedError('ListTodosUsecase is not bound'),
  );

  /// Creates a [ListTodosUsecase].
  const ListTodosUsecase();

  /// Loads the current todo list.
  Future<List<Todo>> execute(ListTodosRequest request);
}
