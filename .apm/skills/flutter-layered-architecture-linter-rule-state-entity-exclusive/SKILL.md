---
name: flutter-layered-architecture-linter-rule-state-entity-exclusive
description: >-
  Flutter Layered Architecture の linter rule `state_entity_exclusive`。
  同一型に `@state` と `@entity` を同時付与しない。
  状態・表示モデル設計、`@state` / `@entity` 型の構造診断の修正では必ず使う。
---
# `@state` と `@entity` の併記禁止（`state_entity_exclusive`）

同一型に `@state` と `@entity` を両方付けない（どちらか一方のみ）。

State と Entity に同じ型を使わせないための制約である。

## いつ使うか

* `state_entity_exclusive` 診断の修正
* State / Entity を別型に分ける設計レビュー

## 関連アノテーション

* `@state`
* `@entity`

## 良い例

```dart
// 状態用
@internal
@state
@freezed
abstract class TodoListScreenState with _$TodoListScreenState { ... }

// 表示用（別型）
@internal
@entity
@freezed
abstract class TodoListScreenEntity with _$TodoListScreenEntity { ... }
```

## 悪い例

```dart
@internal
@state
@entity // → state_entity_exclusive
@freezed
abstract class Both with _$Both { ... }
```

## 抑制

```dart
// ignore: flutter_layered_architecture_lint/state_entity_exclusive
```

## 関連

* `viewmodel_entity_differs_from_state`（ViewModel 側の型分離）
* 関連 linter rule: `state_entity_freezed`