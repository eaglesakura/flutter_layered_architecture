---
name: flutter-layered-architecture-linter-rule-state-entity-freezed
description: >-
  Flutter Layered Architecture の linter rule `state_entity_freezed`。
  `@state` / `@entity` 型には `@freezed` / `@Freezed()` を併記する。
  状態・表示モデルの新規作成、ゲート A 診断の修正では必ず使う。
---
# `@state` / `@entity` は Freezed（`state_entity_freezed`）

ゲート A: `@state` または `@entity` が付いた型は Freezed 付きである必要がある。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。

## いつ使うか

* `state_entity_freezed` 診断の修正
* ルート State / Entity モデルの新規作成

## 関連アノテーション

* `@state` / `@entity`
* `@freezed` / `@Freezed()`（freezed_annotation）
* `@internal`（`state_entity_internal`）

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
@state
final class PlainState {} // → state_entity_freezed
```

## 抑制

```dart
// ignore: flutter_layered_architecture_lint/state_entity_freezed
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* アノテーション package: `flutter_layered_architecture_annotations`
* 関連 linter rule: `state_entity_internal`, `state_entity_required_parameters`