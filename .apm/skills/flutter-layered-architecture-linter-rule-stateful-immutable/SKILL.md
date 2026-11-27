---
name: flutter-layered-architecture-linter-rule-stateful-immutable
description: >-
  Flutter Layered Architecture の linter rule `stateful_immutable`。
  `@stateful` / `@viewModel` は final フィールドと const コンストラクタを持つ。
  @viewModel / Screen ViewModel の実装・修正、診断 `stateful_immutable` の修正、規約に沿った設計では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# @stateful のイミュータブル構造（`stateful_immutable`）

`@stateful` / `@viewModel` は final フィールドと const コンストラクタを持つ。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。
コマンド実行時は、プロジェクト規定のツールチェイン（あれば）に従う。

## いつ使うか

* `stateful_immutable` 診断の修正・抑制判断
* @viewModel / Screen ViewModel の実装・修正
* 関連ルール（`stateful_has_mutable_state_stream`, `viewmodel_internal`）と合わせて規約を満たす設計をするとき

## 関連アノテーション

* `@stateful`
* `@viewModel`

## 推奨設計

* 状態の正本は MutableStateStream。型自体のフィールドは差し替えない

## ルールが検証すること

* フィールドがすべて final/const でない、または const コンストラクタが無いと WARNING

## 良い例

```dart
@stateful
final class Store {
  const Store({required this.state});
  final MutableStateStream<StoreState> state;
}
```

## 悪い例

```dart
@stateful
final class Bad {
  Bad(this.state);
  MutableStateStream<StoreState> state; // → stateful_immutable
}
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/stateful_immutable
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* アノテーション package: `flutter_layered_architecture_annotations`
* 関連 linter rule: `stateful_has_mutable_state_stream`, `viewmodel_internal`
