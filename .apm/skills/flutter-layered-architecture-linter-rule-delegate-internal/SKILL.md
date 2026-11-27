---
name: flutter-layered-architecture-linter-rule-delegate-internal
description: >-
  Flutter Layered Architecture の linter rule `delegate_internal`。
  `@delegate` 型には `@internal` を併記する。
  @delegate の実装・修正、処理切り出し、診断 `delegate_internal` の修正、規約に沿った設計では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# @delegate に @internal（`delegate_internal`）

`@delegate` 型には `@internal` を併記する。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。
コマンド実行時は、プロジェクト規定のツールチェイン（あれば）に従う。

## いつ使うか

* `delegate_internal` 診断の修正・抑制判断
* @delegate の実装・修正、処理切り出し
* 関連ルール（`delegate_execute_method`, `unexported_public_must_be_internal`）と合わせて規約を満たす設計をするとき

## 関連アノテーション

* `@delegate`
* `@internal（package:meta）`

## 推奨設計

* Delegate はパッケージ内実装詳細であり公開 API に載せない
* バレル未 export と合わせて `@internal` で意図を明示する

## ルールが検証すること

* `@delegate` があるのに `@internal` / `@Internal` が無いと WARNING

## 良い例

```dart
@internal
@delegate
final class OnAddTodoDelegate { ... }
```

## 悪い例

```dart
@delegate
final class OnAddTodoDelegate { ... } // → delegate_internal
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/delegate_internal
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* アノテーション package: `flutter_layered_architecture_annotations`
* 関連 linter rule: `delegate_execute_method`, `unexported_public_must_be_internal`
