---
name: flutter-layered-architecture-linter-rule-viewmodel-internal
description: >-
  Flutter Layered Architecture の linter rule `viewmodel_internal`。
  `@viewModel` 型には `@internal` を併記する。
  @viewModel / Screen ViewModel の実装・修正、診断 `viewmodel_internal` の修正、規約に沿った設計では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# @viewModel に @internal（`viewmodel_internal`）

`@viewModel` 型には `@internal` を併記する。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。
コマンド実行時は、プロジェクト規定のツールチェイン（あれば）に従う。

## いつ使うか

* `viewmodel_internal` 診断の修正・抑制判断
* @viewModel / Screen ViewModel の実装・修正
* 関連ルール（`viewmodel_has_entity_getter`, `delegate_internal`）と合わせて規約を満たす設計をするとき

## 関連アノテーション

* `@viewModel`
* `@internal（package:meta）`

## 推奨設計

* ViewModel は Screen パッケージ内の実装詳細として扱う

## ルールが検証すること

* `@viewModel` があるのに `@internal` が無いと WARNING

## 良い例

```dart
@internal
@viewModel
final class TodoListScreenViewModel { ... }
```

## 悪い例

```dart
@viewModel
final class TodoListScreenViewModel { ... } // → viewmodel_internal
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/viewmodel_internal
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* アノテーション package: `flutter_layered_architecture_annotations`
* 関連 linter rule: `viewmodel_has_entity_getter`, `delegate_internal`
