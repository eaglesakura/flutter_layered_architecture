/// `@stateful` 記法用の定数インスタンス.
///
/// Example:
/// ```dart
/// @stateful
/// final class TodoListScreenViewModel {
///   const TodoListScreenViewModel({required this.state});
///
///   final MutableStateStream<TodoListScreenState> state;
///
///   Future<void> close() => state.close();
/// }
/// ```
const stateful = Stateful();

/// Flutter Layered Architecture における状態保持型を示すアノテーション.
///
/// `MutableStateStream` を保持する ViewModel 等に付与し、
/// `flutter_layered_architecture_lint` が構造を検証できるようにする.
///
/// NOTE.
/// フィールドはすべて `final`、コンストラクタは `const` とする.
/// `MutableStateStream<T>` フィールドを持ち、いずれかの経路で
/// `MutableStateStream.close()` が呼ばれている必要がある.
///
/// Example:
/// ```dart
/// @stateful
/// final class TodoListScreenViewModel {
///   const TodoListScreenViewModel({required this.state});
///
///   final MutableStateStream<TodoListScreenState> state;
///
///   Future<void> close() => state.close();
/// }
/// ```
final class Stateful {
  /// [Stateful] アノテーションを生成する.
  ///
  /// Example:
  /// ```dart
  /// const annotation = Stateful();
  /// ```
  const Stateful();
}
