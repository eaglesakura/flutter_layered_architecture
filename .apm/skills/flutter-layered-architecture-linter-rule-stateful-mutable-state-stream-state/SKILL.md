---
name: flutter-layered-architecture-linter-rule-stateful-mutable-state-stream-state
description: >-
  Flutter Layered Architecture の linter rule `stateful_mutable_state_stream_state`。
  `MutableStateStream<T>` の `T` は `@state` 付き class にする。
  @viewModel / Repository / 診断 `stateful_mutable_state_stream_state` の修正では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# MutableStateStream の型引数は @state（`stateful_mutable_state_stream_state`）

`@stateful` / `@viewModel` の `MutableStateStream<T>` について、型引数 `T` に `@state` があることだけを検証する。Freezed 等の構造は `@state` 型に対する `state_entity_*` に委譲する。

**破壊的変更:** 参照元での Freezed 直接検査は廃止され、`@state` 必須に置き換わった。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。

## いつ使うか

* `stateful_mutable_state_stream_state` 診断の修正・抑制判断
* `@stateful` / `@viewModel` 実装の改修

## 関連アノテーション

* `@stateful`
* `@viewModel`
* `@state`（状態モデル型に付与）

## 推奨設計

* 状態モデルは `@internal` + `@state` + `@freezed`
* updateWithLock 内で copyWith する流れと相性が良い

## ルールが検証すること

* `MutableStateStream<T>` の `T` に `@state` が無いと WARNING（Freezed のみでは不足）

## 良い例

```dart
@internal
@state
@freezed
abstract class StoreState with _$StoreState {
  const factory StoreState({required String title}) = _StoreState;
}

@stateful
final class Store {
  const Store({required this.state});
  final MutableStateStream<StoreState> state;
  Future<void> close() => state.close();
}
```

## 悪い例

```dart
@freezed
abstract class StoreState with _$StoreState { ... } // @state なし

@stateful
final class Store {
  const Store({required this.state});
  final MutableStateStream<StoreState> state; // → stateful_mutable_state_stream_state
}
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/stateful_mutable_state_stream_state
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* 型構造: `state_entity_*` ルール群
* 関連 linter rule: `stateful_has_mutable_state_stream`, `viewmodel_entity_annotated`