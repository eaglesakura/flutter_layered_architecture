import 'package:data_repository_todo/data_repository_todo.dart';
import 'package:domain_todo/domain_todo.dart';
import 'package:usecase_todo/usecase_todo.dart';

/// Default [ToggleTodoUsecase] implementation.
final class ToggleTodoUsecaseImpl implements ToggleTodoUsecase {
  final TodoRepository _todoRepository;

  /// Creates an implementation that writes through [_todoRepository].
  const ToggleTodoUsecaseImpl(this._todoRepository);

  @override
  Future<Todo> execute(ToggleTodoRequest request) async {
    final todos = await _todoRepository.list();
    final current = todos.firstWhere(
      (todo) => todo.id == request.id,
      orElse: () => throw StateError('Todo not found: ${request.id}'),
    );
    return _todoRepository.update(
      current.copyWith(isCompleted: !current.isCompleted),
    );
  }
}
