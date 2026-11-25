import 'package:data_repository_todo/data_repository_todo.dart';
import 'package:data_repository_todo_impl/data_repository_todo_impl.dart';
import 'package:foundation_dependency_injection/foundation_dependency_injection.dart';

/// Data レイヤー実装の provider 結線.
final class DataInjectionBindings {
  /// [DataInjectionBindings] を生成する.
  const DataInjectionBindings();

  /// [builder] に TodoRepository 実装を登録する.
  void bind(DependencyBuilder builder) {
    builder.inject(TodoRepository.provider, InMemoryTodoRepository.provider);
  }
}
