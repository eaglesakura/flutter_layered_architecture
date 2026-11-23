import 'package:data_repository_todo/data_repository_todo.dart';
import 'package:data_repository_todo_impl/data_repository_todo_impl.dart';
import 'package:foundation_dependency_injection/foundation_dependency_injection.dart';
import 'package:usecase_todo/usecase_todo.dart';
import 'package:usecase_todo_impl/usecase_todo_impl.dart';

/// Binds sample interface providers to implementations.
final class ExampleDependencyInjection {
  /// Creates an [ExampleDependencyInjection].
  const ExampleDependencyInjection();

  /// Registers todo feature bindings on [builder].
  void bind(DependencyBuilder builder) {
    builder.inject(TodoRepository.provider, InMemoryTodoRepository.provider);
    builder.inject(ListTodosUsecase.provider, ListTodosUsecaseImpl.provider);
    builder.inject(AddTodoUsecase.provider, AddTodoUsecaseImpl.provider);
    builder.inject(ToggleTodoUsecase.provider, ToggleTodoUsecaseImpl.provider);
    builder.inject(DeleteTodoUsecase.provider, DeleteTodoUsecaseImpl.provider);
  }
}
