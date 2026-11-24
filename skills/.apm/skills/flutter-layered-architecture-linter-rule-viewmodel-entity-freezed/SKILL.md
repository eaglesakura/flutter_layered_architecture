---
name: flutter-layered-architecture-linter-rule-viewmodel-entity-freezed
description: >-
  Flutter Layered Architecture の linter rule `viewmodel_entity_freezed`。
  `entity` の `StateStream<T>` の `T` は Freezed 付き class。
  @viewModel / Screen ViewModel の実装・修正、診断 `viewmodel_entity_freezed` の修正、規約に沿った設計では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# entity 型引数は Freezed（`viewmodel_entity_freezed`）

`entity` の `StateStream<T>` の `T` は Freezed 付き class。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。
コマンド実行時は、プロジェクト規定のツールチェイン（あれば）に従う。

## いつ使うか

* `viewmodel_entity_freezed` 診断の修正・抑制判断
* @viewModel / Screen ViewModel の実装・修正
* 関連ルール（`viewmodel_has_entity_getter`, `stateful_mutable_state_stream_freezed`）と合わせて規約を満たす設計をするとき

## 関連アノテーション

* `@viewModel`
* `@freezed / @Freezed()`

## 推奨設計

* 画面表示モデルも不変・copyWith 可能にし、Golden / テストで組み立てやすくする

## ルールが検証すること

* entity の型引数に Freezed が無いと WARNING

## 良い例

```dart
@freezed
abstract class TodoListScreenEntity with _$TodoListScreenEntity { ... }

StateStream<TodoListScreenEntity> get entity => ...;
```

## 悪い例

```dart
final class TodoListScreenEntity { ... }
StateStream<TodoListScreenEntity> get entity => ...; // → viewmodel_entity_freezed
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/viewmodel_entity_freezed
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* アノテーション package: `flutter_layered_architecture_annotations`
* 関連 linter rule: `viewmodel_has_entity_getter`, `stateful_mutable_state_stream_freezed`
