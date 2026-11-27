---
name: flutter-layered-architecture-linter-rule-one-public-type-per-file
description: >-
  Flutter Layered Architecture の linter rule `one_public_type_per_file`。
  1つの Dart ファイルに public な名前付き型を2つ以上置かない。
  ファイル分割・公開 API・バレル設計、診断 `one_public_type_per_file` の修正、規約に沿った設計では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# 1 ファイル 1 public 型（`one_public_type_per_file`）

1つの Dart ファイルに public な名前付き型を2つ以上置かない。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。
コマンド実行時は、プロジェクト規定のツールチェイン（あれば）に従う。

## いつ使うか

* `one_public_type_per_file` 診断の修正・抑制判断
* ファイル分割・公開 API・バレル設計
* 関連ルール（`public_type_file_name`）と合わせて規約を満たす設計をするとき

## 関連アノテーション

* （アノテーション非依存。ファイルレイアウト規約）

## 推奨設計

* 公開 API 面は「型 = ファイル」でナビゲートしやすくする
* 複数型が必要なときは private（`_`）にするかファイルを分割する
* `part of` / `test/` 配下は対象外

## ルールが検証すること

* public な class / enum / mixin / 名前付き extension / extension type が同一ファイルに2つ以上あると WARNING

## 良い例

```dart
// add_todo_request.dart
final class AddTodoRequest {
  const AddTodoRequest({required this.title});
  final String title;
}
```

## 悪い例

```dart
// models.dart
final class AddTodoRequest { ... }
final class ListTodosRequest { ... } // → one_public_type_per_file
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/one_public_type_per_file
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* アノテーション package: `flutter_layered_architecture_annotations`
* 関連 linter rule: `public_type_file_name`
