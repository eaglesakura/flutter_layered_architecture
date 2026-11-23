import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usecase_todo/src/delete_todo_request.dart';

/// Deletes a todo item.
@usecase
abstract interface class DeleteTodoUsecase {
  /// Provides [DeleteTodoUsecase]. Must be overridden by an implementation package.
  static final provider = Provider<DeleteTodoUsecase>(
    (ref) => throw UnimplementedError('DeleteTodoUsecase is not bound'),
  );

  /// Creates a [DeleteTodoUsecase].
  const DeleteTodoUsecase();

  /// Removes the todo identified by [request].
  Future<void> execute(DeleteTodoRequest request);
}
