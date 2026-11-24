---
name: flutter-layered-architecture-linter-rule-viewmodel-entity-differs-from-state
description: >-
  Flutter Layered Architecture の linter rule `viewmodel_entity_differs_from_state`。
  `entity` のモデル型は `MutableStateStream` の状態型と異なる必要がある。
  @viewModel / Screen ViewModel の実装・修正、診断 `viewmodel_entity_differs_from_state` の修正、規約に沿った設計では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# entity と state モデルは別型（`viewmodel_entity_differs_from_state`）

`entity` のモデル型は `MutableStateStream` の状態型と異なる必要がある。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。
コマンド実行時は、プロジェクト規定のツールチェイン（あれば）に従う。

## いつ使うか

* `viewmodel_entity_differs_from_state` 診断の修正・抑制判断
* @viewModel / Screen ViewModel の実装・修正
* 関連ルール（`viewmodel_has_entity_getter`, `viewmodel_entity_freezed`）と合わせて規約を満たす設計をするとき

## 関連アノテーション

* `@viewModel`

## 推奨設計

* State はドメイン寄り、Entity は表示寄りに分離する
* 同じ型を流すと View が内部状態に結合する

## ルールが検証すること

* entity の型引数と MutableStateStream の型引数が同一だと WARNING

## 良い例

```dart
final MutableStateStream<TodoListScreenState> state;
StateStream<TodoListScreenEntity> get entity => ...;
```

## 悪い例

```dart
final MutableStateStream<TodoListScreenState> state;
StateStream<TodoListScreenState> get entity => state; // → viewmodel_entity_differs_from_state
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/viewmodel_entity_differs_from_state
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* アノテーション package: `flutter_layered_architecture_annotations`
* 関連 linter rule: `viewmodel_has_entity_getter`, `viewmodel_entity_freezed`
