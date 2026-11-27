/// `@entity` 記法用の定数インスタンス.
///
/// Example:
/// ```dart
/// @internal
/// @entity
/// @freezed
/// abstract class TodoListScreenEntity with _$TodoListScreenEntity { ... }
/// ```
const entity = Entity();

/// Flutter Layered Architecture における画面表示モデル型を示すアノテーション.
///
/// `StateStream<T> get entity` の型引数 `T` になりうる Freezed モデルに付与する.
/// ネストした表示モデルへの付与は任意（ルートの `T` のみ参照元検査で必須とする）.
///
/// NOTE.
/// `@state` との同時付与は WARNING.
/// 構築規約は `@state` と同じ（全引数 `required`・named factory 禁止）.
///
/// Example:
/// ```dart
/// @internal
/// @entity
/// @freezed
/// abstract class TodoListScreenEntity with _$TodoListScreenEntity { ... }
/// ```
final class Entity {
  /// [Entity] アノテーションを生成する.
  ///
  /// Example:
  /// ```dart
  /// const annotation = Entity();
  /// ```
  const Entity();
}
