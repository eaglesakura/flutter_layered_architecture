import 'package:data_repository_todo/data_repository_todo.dart';
import 'package:domain_todo/domain_todo.dart';

/// In-memory [TodoRepository] for the sample app (Web / demo).
final class InMemoryTodoRepository implements TodoRepository {
  final List<Todo> _items = [];

  @override
  Future<List<Todo>> list() async {
    return List<Todo>.unmodifiable(_items);
  }

  @override
  Future<Todo> add(Todo todo) async {
    _items.insert(0, todo);
    return todo;
  }

  @override
  Future<Todo> update(Todo todo) async {
    final index = _items.indexWhere((item) => item.id == todo.id);
    if (index < 0) {
      throw StateError('Todo not found: ${todo.id}');
    }
    _items[index] = todo;
    return todo;
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
  }
}
