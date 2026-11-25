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

* 唯一の public 名前付き型について、ファイル basename が期待名と一致しないと WARNING
* 期待名は型名の lower_snake_case。任意で最寄りの `layered_architecture.yaml` の
  `rules.public_type_file_name.keywords` により、CamelCase キーワードをファイル名用文字列へ置換できる
* キーワードは YAML 記載順。先勝ち。大文字小文字は厳密一致（`UseCase` 設定は型名 `Usecase` に効かない）
* `rules` / `keywords` 未設定なら従来どおりの変換のみ

## 良い例

```dart
// add_todo_usecase.dart
@usecase
abstract interface class AddTodoUsecase { ... }
```

```dart
// add_todo_usecase.dart（keywords: UseCase: usecase）
@usecase
abstract interface class AddTodoUseCase { ... }
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
