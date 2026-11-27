---
name: flutter-layered-architecture-linter-rule-stateful-has-mutable-state-stream
description: >-
  Flutter Layered Architecture の linter rule `stateful_has_mutable_state_stream`。
  `@stateful` / `@viewModel` は `MutableStateStream` フィールドを持つ。
  @viewModel / Screen ViewModel の実装・修正、診断 `stateful_has_mutable_state_stream` の修正、規約に沿った設計では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# @stateful は MutableStateStream を持つ（`stateful_has_mutable_state_stream`）

`@stateful` / `@viewModel` は `MutableStateStream` フィールドを持つ。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。
コマンド実行時は、プロジェクト規定のツールチェイン（あれば）に従う。

## いつ使うか

* `stateful_has_mutable_state_stream` 診断の修正・抑制判断
* @viewModel / Screen ViewModel の実装・修正
* 関連ルール（`stateful_closes_mutable_state_stream`, `stateful_mutable_state_stream_state`, `pub-flutter-state-stream`）と合わせて規約を満たす設計をするとき

## 関連アノテーション

* `@stateful`
* `@viewModel`

## 推奨設計

* 可変状態は MutableStateStream に集約する（バラの可変フィールドを避ける）
* 外部には StateStream として公開するパターンを推奨

## ルールが検証すること

* MutableStateStream 型のフィールドが無いと WARNING

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
  const Bad({required this.title});
  final String title; // → stateful_has_mutable_state_stream
}
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/stateful_has_mutable_state_stream
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* アノテーション package: `flutter_layered_architecture_annotations`
* 関連 linter rule: `stateful_closes_mutable_state_stream`, `stateful_mutable_state_stream_state`, `pub-flutter-state-stream`
