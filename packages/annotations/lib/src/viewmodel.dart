/// `@viewModel` 記法用の定数インスタンス.
///
/// Example:
/// ```dart
/// @internal
/// @viewModel
/// final class TodoListScreenViewModel {
///   const TodoListScreenViewModel({required this.state});
///
///   final MutableStateStream<TodoListScreenState> state;
///
///   StateStream<TodoListScreenEntity> get entity => state.map(...);
///
///   Future<void> close() => state.close();
/// }
/// ```
const viewModel = ViewModel();

/// Flutter Layered Architecture における ViewModel 型を示すアノテーション.
///
/// `@stateful` の制約を引き継ぎ、画面向け ViewModel に追加の規約を課す.
/// `flutter_layered_architecture_lint` が構造を検証できるようにする.
///
/// NOTE.
/// `@stateful` と同じく、フィールドはすべて `final`、コンストラクタは `const`、
/// `MutableStateStream<T>`（`T` は `@state` 付き Freezed）を持ち、
/// `MutableStateStream.close()` 呼び出しと `@delegate` への委譲が必要である.
/// 加えて `@internal` の併記、`StateStream<T> get entity` の宣言が必須である.
/// `entity` の `T` には `@entity` が必須（構造はゲート A で検査）.
/// `entity` のモデル型は `MutableStateStream` の状態モデル型とは異なる必要がある.
/// `close` / `_close` を除くインスタンスメソッドおよび
/// 当該型への extension method は、名前が `on` で始まる必要がある.
///
/// Example:
/// ```dart
/// @internal
/// @viewModel
/// final class TodoListScreenViewModel {
///   const TodoListScreenViewModel({required this.state});
///
///   final MutableStateStream<TodoListScreenState> state;
///
///   StateStream<TodoListScreenEntity> get entity => state.map(...);
///
///   Future<void> close() => state.close();
/// }
/// ```
final class ViewModel {
  /// [ViewModel] アノテーションを生成する.
  ///
  /// Example:
  /// ```dart
  /// const annotation = ViewModel();
  /// ```
  const ViewModel();
}
