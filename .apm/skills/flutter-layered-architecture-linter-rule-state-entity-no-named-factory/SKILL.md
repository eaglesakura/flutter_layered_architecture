---
name: flutter-layered-architecture-linter-rule-state-entity-no-named-factory
description: >-
  Flutter Layered Architecture の linter rule `state_entity_no_named_factory`。
  `@state` / `@entity` 型に named factory（例: `.initial()`）を定義しない。
  状態・表示モデルの新規作成、`@state` / `@entity` 型の構造診断の修正では必ず使う。
---
# named factory 禁止（`state_entity_no_named_factory`）

`@state` / `@entity` 型では named factory（`factory Foo.bar()`）を定義しない。

初期値の省略は呼び出し側で主 factory の全引数を明示する。

## いつ使うか

* `state_entity_no_named_factory` 診断の修正
* `.initial()` 等を削除する破壊的移行

## 関連アノテーション

* `@state` / `@entity`

## 良い例

```dart
// 呼び出し側
const TodoListScreenState(
  isLoading: true,
  todos: [],
  draftTitle: '',
);
```

## 悪い例

```dart
@internal
@state
@freezed
abstract class Bad with _$Bad {
  const factory Bad({required int value}) = _Bad;

  factory Bad.zero() => const Bad(value: 0); // → state_entity_no_named_factory
}
```

## 抑制

```dart
// ignore: flutter_layered_architecture_lint/state_entity_no_named_factory
```

## 関連

* 関連 linter rule: `state_entity_required_parameters`