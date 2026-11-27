---
name: flutter-layered-architecture-linter-rule-stateful-closes-mutable-state-stream
description: >-
  Flutter Layered Architecture の linter rule `stateful_closes_mutable_state_stream`。
  `@stateful` / `@viewModel` 内のいずれかの経路で `MutableStateStream.close()` を呼ぶ。
  @viewModel / Screen ViewModel の実装・修正、診断 `stateful_closes_mutable_state_stream` の修正、規約に沿った設計では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# MutableStateStream.close の呼び出し（`stateful_closes_mutable_state_stream`）

`@stateful` / `@viewModel` 内のいずれかの経路で `MutableStateStream.close()` を呼ぶ。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。
コマンド実行時は、プロジェクト規定のツールチェイン（あれば）に従う。

## いつ使うか

* `stateful_closes_mutable_state_stream` 診断の修正・抑制判断
* @viewModel / Screen ViewModel の実装・修正
* 関連ルール（`stateful_has_mutable_state_stream`, `stateful_methods_use_delegate`）と合わせて規約を満たす設計をするとき

## 関連アノテーション

* `@stateful`
* `@viewModel`

## 推奨設計

* `close` / `_close` で stream を閉じ、リークを防ぐ
* close 本体は Delegate 委譲の例外として許容される

## ルールが検証すること

* 型のメソッド群に MutableStateStream.close 呼び出しが無いと WARNING

## 良い例

```dart
@stateful
final class Store {
  const Store({required this.state});
  final MutableStateStream<StoreState> state;
  Future<void> close() => state.close();
}
```

## 悪い例

```dart
@stateful
final class Bad {
  const Bad({required this.state});
  final MutableStateStream<StoreState> state;
  // close 無し → stateful_closes_mutable_state_stream
}
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/stateful_closes_mutable_state_stream
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* アノテーション package: `flutter_layered_architecture_annotations`
* 関連 linter rule: `stateful_has_mutable_state_stream`, `stateful_methods_use_delegate`
