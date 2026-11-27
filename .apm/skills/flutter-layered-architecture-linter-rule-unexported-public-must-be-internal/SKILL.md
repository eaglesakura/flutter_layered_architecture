---
name: flutter-layered-architecture-linter-rule-unexported-public-must-be-internal
description: >-
  Flutter Layered Architecture の linter rule `unexported_public_must_be_internal`。
  lib/ バレル（library;）に export されていない公開トップレベルは `@internal` か private にする。
  ファイル分割・公開 API・バレル設計、診断 `unexported_public_must_be_internal` の修正、規約に沿った設計では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# バレル未公開シンボルは @internal（`unexported_public_must_be_internal`）

lib/ バレル（library;）に export されていない公開トップレベルは `@internal` か private にする。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。
コマンド実行時は、プロジェクト規定のツールチェイン（あれば）に従う。

## いつ使うか

* `unexported_public_must_be_internal` 診断の修正・抑制判断
* ファイル分割・公開 API・バレル設計
* 関連ルール（`one_public_type_per_file`, `public_type_file_name`）と合わせて規約を満たす設計をするとき

## 関連アノテーション

* `@internal（package:meta）`

## 推奨設計

* パッケージ公開面は `lib/*.dart` の `library;` + `export` に集約する
* `lib/src/` の実装型はバレルに載せないなら `@internal` を付ける
* バレルが無いパッケージではスキップされる

## ルールが検証すること

* バレルの export 名前空間に無い public トップレベル（型・関数・変数・typedef 等）に `@internal` が無いと WARNING
* `part of` / `test/` は対象外

## 良い例

```dart
// lib/src/hidden_helper.dart
@internal
final class HiddenHelper { ... }
```

## 悪い例

```dart
// lib/src/hidden_helper.dart（バレル未 export）
final class HiddenHelper { ... } // → unexported_public_must_be_internal
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/unexported_public_must_be_internal
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* アノテーション package: `flutter_layered_architecture_annotations`
* 関連 linter rule: `one_public_type_per_file`, `public_type_file_name`
