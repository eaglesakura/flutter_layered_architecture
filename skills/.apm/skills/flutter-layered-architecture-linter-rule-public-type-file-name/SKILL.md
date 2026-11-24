---
name: flutter-layered-architecture-linter-rule-public-type-file-name
description: >-
  Flutter Layered Architecture の linter rule `public_type_file_name`。
  唯一の public 型名を lower_snake_case にしたファイル名にする。
  ファイル分割・公開 API・バレル設計、診断 `public_type_file_name` の修正、規約に沿った設計では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# public 型名とファイル名の一致（`public_type_file_name`）

唯一の public 型名を lower_snake_case にしたファイル名にする。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。
コマンド実行時は、プロジェクト規定のツールチェイン（あれば）に従う。

## いつ使うか

* `public_type_file_name` 診断の修正・抑制判断
* ファイル分割・公開 API・バレル設計
* 関連ルール（`one_public_type_per_file`）と合わせて規約を満たす設計をするとき

## 関連アノテーション

* （アノテーション非依存。ファイルレイアウト規約）

## 推奨設計

* 型を探すときパスと識別子が一致するとレビュー・検索が速い
* public 型が0個または2個以上のときは本ルールは報告しない（件数は one_public_type_per_file）

## ルールが検証すること

* 唯一の public 名前付き型について、ファイル basename が `pascal_to_snake(型名).dart` でないと WARNING

## 良い例

```dart
// add_todo_usecase.dart
@usecase
abstract interface class AddTodoUsecase { ... }
```

## 悪い例

```dart
// usecase.dart
@usecase
abstract interface class AddTodoUsecase { ... } // → public_type_file_name
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/public_type_file_name
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* アノテーション package: `flutter_layered_architecture_annotations`
* 関連 linter rule: `one_public_type_per_file`
