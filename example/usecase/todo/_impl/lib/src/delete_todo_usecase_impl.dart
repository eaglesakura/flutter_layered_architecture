import 'package:data_repository_todo/data_repository_todo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usecase_todo/usecase_todo.dart';

/// Default [DeleteTodoUsecase] implementation.
final class DeleteTodoUsecaseImpl implements DeleteTodoUsecase {
  /// Provides [DeleteTodoUsecaseImpl].
  static final provider = Provider<DeleteTodoUsecaseImpl>(
    (ref) => DeleteTodoUsecaseImpl(ref.watch(TodoRepository.provider)),
    dependencies: [TodoRepository.provider],
  );

  final TodoRepository _todoRepository;

  /// Creates an implementation that writes through [_todoRepository].
  const DeleteTodoUsecaseImpl(this._todoRepository);

  @override
  Future<void> execute(DeleteTodoRequest request) {
    return _todoRepository.delete(request.id);
  }
}
