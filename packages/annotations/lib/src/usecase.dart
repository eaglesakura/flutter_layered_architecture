/// Const instance for `@usecase` syntax.
const usecase = Usecase();

/// Marks a type as a Usecase in Flutter Layered Architecture.
///
/// Apply to Usecase interfaces (and optionally implementations) so that
/// `flutter_layered_architecture_lint` can validate structure.
///
/// Example:
/// ```dart
/// @usecase
/// abstract interface class ListTodosUsecase {
///   Future<List<Todo>> execute();
/// }
/// ```
final class Usecase {
  /// Creates a [Usecase] annotation.
  const Usecase();
}
