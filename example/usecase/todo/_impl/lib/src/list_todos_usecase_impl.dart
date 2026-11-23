import 'package:data_repository_todo/data_repository_todo.dart';
import 'package:domain_todo/domain_todo.dart';
import 'package:usecase_todo/usecase_todo.dart';

/// Default [ListTodosUsecase] implementation.
final class ListTodosUsecaseImpl implements ListTodosUsecase {
  final TodoRepository _todoRepository;

  /// Creates an implementation that reads from [_todoRepository].
  const ListTodosUsecaseImpl(this._todoRepository);

  @override
  Future<List<Todo>> execute() => _todoRepository.list();
}
