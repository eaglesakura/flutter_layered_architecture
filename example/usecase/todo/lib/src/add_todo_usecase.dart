import 'package:domain_todo/domain_todo.dart';
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Request for [AddTodoUsecase].
final class AddTodoRequest {
  /// Title entered by the user.
  final String title;

  /// Creates an [AddTodoRequest].
  const AddTodoRequest({required this.title});
}

/// Adds a new todo item.
@usecase
abstract interface class AddTodoUsecase {
  /// Provides [AddTodoUsecase]. Must be overridden by an implementation package.
  static final provider = Provider<AddTodoUsecase>(
    (ref) => throw UnimplementedError('AddTodoUsecase is not bound'),
  );

  /// Creates an [AddTodoUsecase].
  const AddTodoUsecase();

  /// Creates and persists a todo from [request].
  Future<Todo> execute(AddTodoRequest request);
}
