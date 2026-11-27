---
name: flutter-layered-architecture-linter-rule-viewmodel-has-entity-getter
description: >-
  Flutter Layered Architecture の linter rule `viewmodel_has_entity_getter`。
  `StateStream<T> get entity` を宣言する。
  @viewModel / Screen ViewModel の実装・修正、診断 `viewmodel_has_entity_getter` の修正、規約に沿った設計では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# @viewModel は entity getter（`viewmodel_has_entity_getter`）

`StateStream<T> get entity` を宣言する。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。
コマンド実行時は、プロジェクト規定のツールチェイン（あれば）に従う。

## いつ使うか

* `viewmodel_has_entity_getter` 診断の修正・抑制判断
* @viewModel / Screen ViewModel の実装・修正
* 関連ルール（`viewmodel_entity_annotated`, `viewmodel_entity_differs_from_state`）と合わせて規約を満たす設計をするとき

## 関連アノテーション

* `@viewModel`

## 推奨設計

* View は Entity だけを watch する（State を直接見せない）
* state.map / Delegate で State→Entity 変換する

## ルールが検証すること

* `StateStream<...> get entity` が無いと WARNING

## 良い例

```dart
@internal
@viewModel
final class TodoListScreenViewModel {
  ...
  StateStream<TodoListScreenEntity> get entity =>
      state.map((s) => TodoListScreenStateToEntityDelegate().execute(s));
}
```

## 悪い例

```dart
@internal
@viewModel
final class Bad {
  final MutableStateStream<TodoListScreenState> state;
  // entity 無し → viewmodel_has_entity_getter
}
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/viewmodel_has_entity_getter
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* アノテーション package: `flutter_layered_architecture_annotations`
* 関連 linter rule: `viewmodel_entity_annotated`, `viewmodel_entity_differs_from_state`
