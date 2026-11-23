import 'package:data_repository_todo/data_repository_todo.dart';
import 'package:domain_todo/domain_todo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usecase_todo/usecase_todo.dart';

/// Default [ListTodosUsecase] implementation.
final class ListTodosUsecaseImpl implements ListTodosUsecase {
  /// Provides [ListTodosUsecaseImpl].
  static final provider = Provider<ListTodosUsecaseImpl>(
    (ref) => ListTodosUsecaseImpl(ref.watch(TodoRepository.provider)),
    dependencies: [TodoRepository.provider],
  );

  final TodoRepository _todoRepository;

  /// Creates an implementation that reads from [_todoRepository].
  const ListTodosUsecaseImpl(this._todoRepository);

  @override
  Future<List<Todo>> execute() => _todoRepository.list();
}
