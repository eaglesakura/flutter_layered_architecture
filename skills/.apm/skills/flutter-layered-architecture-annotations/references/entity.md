# `@entity`

`StateStream<T> get entity` の型引数 `T` になりうる **画面表示モデル** に付与する。
構造・構築規約は **ゲート A**、ゲート B ではルートの `entity` の `T` に `@entity` があることだけを要求する。

## いつ付けるか

* ViewModel の `entity` が流す表示用 Freezed モデルを定義するとき
* ルートの `StateStream<T> get entity` の `T`

ネストした表示モデル（例: リスト項目 Entity）への `@entity` は任意。

## 付与先

* **型**
* バレル `library` には付けない

## 必須併記

* `@internal`（`package:meta`）
* `@freezed` / `@Freezed()`（`freezed_annotation`）
* 同一型に `@state` は付けない（併記は `state_entity_exclusive`）

## 構築規約（ゲート A）

`@state` と同じ（全引数 `required`、named factory 禁止）。詳細は [state.md](./state.md) の構築規約を参照。

## 付与後に効く Lint

### ゲート A

| Lint code | 要点 |
| --- | --- |
| `state_entity_freezed` | Freezed 併記 |
| `state_entity_internal` | `@internal` 併記 |
| `state_entity_exclusive` | `@state` と `@entity` の同時付与禁止 |
| `state_entity_required_parameters` | 主 factory: 全 `required`、デフォルト無し |
| `state_entity_no_named_factory` | named factory 禁止 |

### ゲート B

| Lint code | 要点 |
| --- | --- |
| `viewmodel_entity_annotated` | `entity` の `T` に `@entity` 必須 |
| `viewmodel_entity_differs_from_state` | `entity` の型は状態モデル型と異なること（維持） |

## 破壊的変更

* ゲート B の Freezed 直接検査は廃止。Freezed だけでは不十分で、**`@entity` が必須**

## 良い例

```dart
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';

part 'todo_list_screen_entity.freezed.dart';

@internal
@entity
@freezed
abstract class TodoListScreenEntity with _$TodoListScreenEntity {
  const factory TodoListScreenEntity({
    required bool isLoading,
    required List<TodoListItemEntity> items,
    required String draftTitle,
  }) = _TodoListScreenEntity;
}
```

## 悪い例

```dart
@entity
final class PlainEntity {} // → state_entity_freezed（Freezed 無し）
```

## DO NOT

* State モデルと同じ型を `entity` に使わない（`viewmodel_entity_differs_from_state`）
* `@state` と同一型に両方付けない
* ルート Entity に `@entity` を付け忘れない