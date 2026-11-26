---
name: flutter-layered-architecture-linter-rule-state-entity-internal
description: >-
  Flutter Layered Architecture の linter rule `state_entity_internal`。
  `@state` / `@entity` 型には `@internal` を併記する。
  状態・表示モデルの新規作成、ゲート A 診断の修正では必ず使う。
---
# `@state` / `@entity` に @internal（`state_entity_internal`）

ゲート A: `@state` または `@entity` が付いた型には `@internal` を併記する。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。

## いつ使うか

* `state_entity_internal` 診断の修正
* State / Entity モデルを Screen パッケージ内に閉じるとき

## 関連アノテーション

* `@state` / `@entity`
* `@internal`（`package:meta`）

## 良い例

```dart
@internal
@state
@freezed
abstract class TodoListScreenState with _$TodoListScreenState { ... }
```

## 悪い例

```dart
@state
@freezed
abstract class Bad with _$Bad { ... } // @internal なし → state_entity_internal
```

## 抑制

```dart
// ignore: flutter_layered_architecture_lint/state_entity_internal
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* 関連 linter rule: `state_entity_freezed`, `viewmodel_internal`