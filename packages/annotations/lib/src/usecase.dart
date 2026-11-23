/// `@usecase` 記法用の定数インスタンス.
///
/// Example:
/// ```dart
/// @usecase
/// abstract interface class ListTodosUsecase {
///   const ListTodosUsecase();
///
///   Future<List<Todo>> execute(ListTodosRequest request);
/// }
/// ```
const usecase = Usecase();

/// Flutter Layered Architecture における Usecase 型を示すアノテーション.
///
/// Usecase の interface（および必要に応じて実装）に付与し、
/// `flutter_layered_architecture_lint` が構造を検証できるようにする.
///
/// Example:
/// ```dart
/// @usecase
/// abstract interface class ListTodosUsecase {
///   const ListTodosUsecase();
///
///   Future<List<Todo>> execute(ListTodosRequest request);
/// }
/// ```
final class Usecase {
  /// [Usecase] アノテーションを生成する.
  ///
  /// Example:
  /// ```dart
  /// const annotation = Usecase();
  /// ```
  const Usecase();
}
