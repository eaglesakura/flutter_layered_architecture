# `@state`

`MutableStateStream<T>` の型引数 `T` になりうる **状態保持モデル** に付与する。
Freezed の構造・構築規約は `state_entity_*` lint が検査し、`@stateful` / `@viewModel` 側は `T` に `@state` があることだけを要求する。

## いつ付けるか

* 画面 ViewModel や Repository が保持する状態モデルを定義するとき
* ルートの `MutableStateStream<T>` の `T` として使う Freezed 型

ネストした型への `@state` は任意（参照元検査 はルートの `T` のみを見る）。

## 付与先

* **型**
* バレル `library` には付けない

## 必須併記

* `@internal`（`package:meta`）
* `@freezed` / `@Freezed()`（`freezed_annotation`）
* 同一型に `@entity` は付けない（併記は `state_entity_exclusive`）

## 構築規約

* 主データ factory の全パラメータは `required` 明示
* `@Default` 禁止
* Dart のデフォルト引数禁止
* named factory（例: `.initial()`）の定義は WARNING（呼び出し側で全引数を書く）

## 付与後に効く Lint

### 注釈付き型自身（`@state` / `@entity`）

| Lint code | 要点 |
| --- | --- |
| `state_entity_freezed` | Freezed 併記 |
| `state_entity_internal` | `@internal` 併記 |
| `state_entity_exclusive` | `@state` と `@entity` の同時付与禁止 |
| `state_entity_required_parameters` | 主 factory: 全 `required`、デフォルト無し |
| `state_entity_no_named_factory` | named factory 禁止 |

### 参照元（`@stateful` / `@viewModel`）

| Lint code | 要点 |
| --- | --- |
| `stateful_mutable_state_stream_state` | `MutableStateStream<T>` の `T` に `@state` 必須 |

詳細は対応する `flutter-layered-architecture-linter-rule-*` SKILL を正とする。

## 破壊的変更

* 参照元での Freezed 直接検査は廃止。Freezed だけでは不十分で、**`@state` が必須**
* `.initial()` 等の named factory は推奨されない（`state_entity_no_named_factory`）

## 良い例

```dart
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';

part 'todo_list_screen_state.freezed.dart';

@internal
@state
@freezed
abstract class TodoListScreenState with _$TodoListScreenState {
  const factory TodoListScreenState({
    required bool isLoading,
    required List<Todo> todos,
    required String draftTitle,
  }) = _TodoListScreenState;
}
```

## 悪い例

```dart
@state
@freezed
abstract class Bad with _$Bad {
  const factory Bad({@Default(0) int x}) = _Bad; // → required_parameters
  factory Bad.initial() => const Bad(x: 0); // → no_named_factory
}
```

## DO NOT

* `@entity` と同一型に両方付けない
* named factory で初期値を隠さない（呼び出し側で全引数を明示する）
* `@stateful` の `T` として使う型に `@state` を付け忘れない