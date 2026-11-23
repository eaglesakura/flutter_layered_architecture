/// `@delegate` 記法用の定数インスタンス.
///
/// Example:
/// ```dart
/// @internal
/// @delegate
/// final class OnAddTodoDelegate {
///   const OnAddTodoDelegate({required this.state});
///
///   final MutableStateStream<TodoListScreenState> state;
///
///   Future<void> execute() async {}
/// }
/// ```
const delegate = Delegate();

/// Flutter Layered Architecture における Delegate 型を示すアノテーション.
///
/// ViewModel 等から切り出した単一処理クラスに付与し、
/// `flutter_layered_architecture_lint` が構造を検証できるようにする.
///
/// NOTE.
/// `@internal`（`package:meta`）の併記が必須である.
/// インスタンスメソッドは `execute` のみとし、フィールドは `final`、
/// コンストラクタは `const` とする.
/// 別の `@delegate` を引数や内部生成で入れ子にしてはならない.
/// `@usecase` 付き型はコンストラクタで受け取り、内部で生成してはならない.
///
/// Example:
/// ```dart
/// @internal
/// @delegate
/// final class OnAddTodoDelegate {
///   const OnAddTodoDelegate({required this.state});
///
///   final MutableStateStream<TodoListScreenState> state;
///
///   Future<void> execute() async {}
/// }
/// ```
final class Delegate {
  /// [Delegate] アノテーションを生成する.
  ///
  /// Example:
  /// ```dart
  /// const annotation = Delegate();
  /// ```
  const Delegate();
}
