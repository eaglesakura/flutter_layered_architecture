---
name: flutter-layered-architecture-linter-rule-viewmodel-entity-annotated
description: >-
  Flutter Layered Architecture の linter rule `viewmodel_entity_annotated`。
  `entity` の `StateStream<T>` の `T` は `@entity` 付き class。
  @viewModel / Screen ViewModel の実装・修正では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# entity 型引数は @entity（`viewmodel_entity_annotated`）

`@viewModel` の `StateStream<T> get entity` について、型引数 `T` に `@entity` があることだけを検証する。Freezed 等の構造は `state_entity_*` に委譲する。

**破壊的変更:** 参照元での Freezed 直接検査は廃止され、`@entity` 必須に置き換わった。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。

## いつ使うか

* `viewmodel_entity_annotated` 診断の修正・抑制判断
* @viewModel / Screen ViewModel の実装・修正

## 関連アノテーション

* `@viewModel`
* `@entity`（表示モデル型に付与）

## 推奨設計

* 画面表示モデルは `@internal` + `@entity` + `@freezed`
* State モデル型とは別型にする（`viewmodel_entity_differs_from_state`）

## ルールが検証すること

* entity の型引数に `@entity` が無いと WARNING（Freezed のみでは不足）

## 良い例

```dart
@internal
@entity
@freezed
abstract class TodoListScreenEntity with _$TodoListScreenEntity { ... }

StateStream<TodoListScreenEntity> get entity => ...;
```

## 悪い例

```dart
@freezed
abstract class TodoListScreenEntity with _$TodoListScreenEntity { ... } // @entity なし

StateStream<TodoListScreenEntity> get entity => ...; // → viewmodel_entity_annotated
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/viewmodel_entity_annotated
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* 型構造: `state_entity_*` ルール群
* 関連 linter rule: `viewmodel_has_entity_getter`, `stateful_mutable_state_stream_state`