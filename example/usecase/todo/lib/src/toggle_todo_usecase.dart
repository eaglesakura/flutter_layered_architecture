import 'package:domain_todo/domain_todo.dart';
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Request for [ToggleTodoUsecase].
final class ToggleTodoRequest {
  /// Target todo id.
  final String id;

  /// Creates a [ToggleTodoRequest].
  const ToggleTodoRequest({required this.id});
}

/// Toggles completion of a todo item.
@usecase
abstract interface class ToggleTodoUsecase {
  /// Provides [ToggleTodoUsecase]. Must be overridden by an implementation package.
  static final provider = Provider<ToggleTodoUsecase>(
    (ref) => throw UnimplementedError('ToggleTodoUsecase is not bound'),
  );

  /// Creates a [ToggleTodoUsecase].
  const ToggleTodoUsecase();

  /// Flips completion for the todo identified by [request].
  Future<Todo> execute(ToggleTodoRequest request);
}
