---
name: flutter-layered-architecture-linter-rule-state-entity-required-parameters
description: >-
  Flutter Layered Architecture の linter rule `state_entity_required_parameters`。
  `@state` / `@entity` の主データ factory は全パラメータ `required` で、
  `@Default` や Dart デフォルト引数を使わない。
  状態・表示モデルの新規作成、`@state` / `@entity` 型の構造診断の修正では必ず使う。
---
# 主 factory は全引数 required（`state_entity_required_parameters`）

`@state` / `@entity` 型の主データ factory（名前なし `factory`）では、

* 全パラメータに `required` 明示
* `@Default` 禁止
* Dart のデフォルト引数禁止

違反パラメータごとに WARNING する。

## いつ使うか

* `state_entity_required_parameters` 診断の修正
* `.initial()` を廃止して呼び出し側で全引数を書く移行

## 関連アノテーション

* `@state` / `@entity`
* `@freezed`

## 良い例

```dart
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
const factory Bad({
  @Default(0) int value, // → state_entity_required_parameters
}) = _Bad;

const factory Bad2({
  int value = 0, // → state_entity_required_parameters
}) = _Bad2;

const factory Bad3({
  int? value, // required 無し → state_entity_required_parameters
}) = _Bad3;
```

## 抑制

```dart
// ignore: flutter_layered_architecture_lint/state_entity_required_parameters
```

## 関連

* 関連 linter rule: `state_entity_no_named_factory`