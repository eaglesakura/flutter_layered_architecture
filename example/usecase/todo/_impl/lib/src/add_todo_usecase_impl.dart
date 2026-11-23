import 'package:data_repository_todo/data_repository_todo.dart';
import 'package:domain_todo/domain_todo.dart';
import 'package:usecase_todo/usecase_todo.dart';
import 'package:uuid/uuid.dart';

/// Default [AddTodoUsecase] implementation.
final class AddTodoUsecaseImpl implements AddTodoUsecase {
  final TodoRepository _todoRepository;

  /// Creates an implementation that writes through [_todoRepository].
  const AddTodoUsecaseImpl(this._todoRepository);

  @override
  Future<Todo> execute(AddTodoRequest request) {
    final title = request.title.trim();
    if (title.isEmpty) {
      throw ArgumentError.value(request.title, 'title', 'must not be empty');
    }
    final todo = Todo(
      id: const Uuid().v4(),
      title: title,
      isCompleted: false,
    );
    return _todoRepository.add(todo);
  }
}
