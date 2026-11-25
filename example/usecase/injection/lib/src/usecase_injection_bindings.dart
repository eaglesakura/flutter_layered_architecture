import 'package:foundation_dependency_injection/foundation_dependency_injection.dart';
import 'package:usecase_todo/usecase_todo.dart';
import 'package:usecase_todo_impl/usecase_todo_impl.dart';

final class UsecaseInjectionBindings {
  const UsecaseInjectionBindings();

  void bind(DependencyBuilder builder) {
    builder.inject(ListTodosUsecase.provider, ListTodosUsecaseImpl.provider);
    builder.inject(AddTodoUsecase.provider, AddTodoUsecaseImpl.provider);
    builder.inject(ToggleTodoUsecase.provider, ToggleTodoUsecaseImpl.provider);
    builder.inject(DeleteTodoUsecase.provider, DeleteTodoUsecaseImpl.provider);
  }
}
