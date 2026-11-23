import 'package:data_repository_todo/data_repository_todo.dart';
import 'package:data_repository_todo_impl/data_repository_todo_impl.dart';
import 'package:riverpod/misc.dart';
import 'package:usecase_todo/usecase_todo.dart';
import 'package:usecase_todo_impl/usecase_todo_impl.dart';

/// Wires interface providers to sample implementations.
final class DependencyBuilder {
  /// Creates a [DependencyBuilder].
  const DependencyBuilder();

  /// Returns Riverpod overrides for the sample app.
  List<Override> build() {
    return [
      TodoRepository.provider.overrideWithValue(InMemoryTodoRepository()),
      ListTodosUsecase.provider.overrideWith(
        (ref) => ListTodosUsecaseImpl(ref.watch(TodoRepository.provider)),
      ),
      AddTodoUsecase.provider.overrideWith(
        (ref) => AddTodoUsecaseImpl(ref.watch(TodoRepository.provider)),
      ),
      ToggleTodoUsecase.provider.overrideWith(
        (ref) => ToggleTodoUsecaseImpl(ref.watch(TodoRepository.provider)),
      ),
      DeleteTodoUsecase.provider.overrideWith(
        (ref) => DeleteTodoUsecaseImpl(ref.watch(TodoRepository.provider)),
      ),
    ];
  }
}
