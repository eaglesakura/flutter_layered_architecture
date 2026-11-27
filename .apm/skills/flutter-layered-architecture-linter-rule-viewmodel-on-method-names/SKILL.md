---
name: flutter-layered-architecture-linter-rule-viewmodel-on-method-names
description: >-
  Flutter Layered Architecture の linter rule `viewmodel_on_method_names`。
  インスタンス / extension メソッドは `on` で始める（close / _close 除く）。
  @viewModel / Screen ViewModel の実装・修正、診断 `viewmodel_on_method_names` の修正、規約に沿った設計では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# @viewModel メソッドは on* 命名（`viewmodel_on_method_names`）

インスタンス / extension メソッドは `on` で始める（close / _close 除く）。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。
コマンド実行時は、プロジェクト規定のツールチェイン（あれば）に従う。

## いつ使うか

* `viewmodel_on_method_names` 診断の修正・抑制判断
* @viewModel / Screen ViewModel の実装・修正
* 関連ルール（`stateful_methods_use_delegate`）と合わせて規約を満たす設計をするとき

## 関連アノテーション

* `@viewModel`

## 推奨設計

* 画面イベント（タップ等）を `onAddTodo` のように揃える
* getter / setter は対象外。close 系は例外

## ルールが検証すること

* on で始まらないインスタンス/extension メソッドがあると WARNING

## 良い例

```dart
extension on TodoListScreenViewModel {
  Future<void> onAddTodo() => OnAddTodoDelegate(...).execute();
}
```

## 悪い例

```dart
extension on TodoListScreenViewModel {
  Future<void> addTodo() async {} // → viewmodel_on_method_names
}
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/viewmodel_on_method_names
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* アノテーション package: `flutter_layered_architecture_annotations`
* 関連 linter rule: `stateful_methods_use_delegate`
