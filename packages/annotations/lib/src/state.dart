/// `@state` 記法用の定数インスタンス.
///
/// Example:
/// ```dart
/// @internal
/// @state
/// @freezed
/// abstract class TodoListScreenState with _$TodoListScreenState {
///   const factory TodoListScreenState({
///     required bool isLoading,
///     required List<Todo> todos,
///     required String draftTitle,
///   }) = _TodoListScreenState;
/// }
/// ```
const state = State();

/// Flutter Layered Architecture における状態保持モデル型を示すアノテーション.
///
/// `MutableStateStream<T>` の型引数 `T` になりうる Freezed モデルに付与し、
/// `flutter_layered_architecture_lint` が型自身の構造および
/// `@stateful` / `@viewModel` からの参照を検証できるようにする.
///
/// NOTE.
/// `@entity` と同一型への同時付与は WARNING（どちらか一方のみ）.
/// 主データ factory の全パラメータは `required` 明示が必須（`@Default`・Dart デフォルト引数禁止）.
/// named factory（例: `.initial()`）の定義は WARNING.
///
/// Example:
/// ```dart
/// @internal
/// @state
/// @freezed
/// abstract class TodoListScreenState with _$TodoListScreenState { ... }
/// ```
final class State {
  /// [State] アノテーションを生成する.
  ///
  /// Example:
  /// ```dart
  /// const annotation = State();
  /// ```
  const State();
}
