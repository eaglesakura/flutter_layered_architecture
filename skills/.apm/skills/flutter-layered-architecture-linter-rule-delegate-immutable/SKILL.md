---
name: flutter-layered-architecture-linter-rule-delegate-immutable
description: >-
  Flutter Layered Architecture の linter rule `delegate_immutable`。
  `@delegate` は final フィールドと const コンストラクタを持つ。
  @delegate の実装・修正、処理切り出し、診断 `delegate_immutable` の修正、規約に沿った設計では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# @delegate のイミュータブル構造（`delegate_immutable`）

`@delegate` は final フィールドと const コンストラクタを持つ。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。
コマンド実行時は、プロジェクト規定のツールチェイン（あれば）に従う。

## いつ使うか

* `delegate_immutable` 診断の修正・抑制判断
* @delegate の実装・修正、処理切り出し
* 関連ルール（`delegate_execute_method`, `delegate_internal`）と合わせて規約を満たす設計をするとき

## 関連アノテーション

* `@delegate`
* `@internal`

## 推奨設計

* 依存と state 参照はすべて final。const で組み立て可能にする

## ルールが検証すること

* フィールドがすべて final/const でない、または const コンストラクタが無いと WARNING

## 良い例

```dart
@internal
@delegate
final class OnInitializeDelegate {
  const OnInitializeDelegate({required this.state, required this.listTodosUsecase});
  final MutableStateStream<TodoListScreenState> state;
  final ListTodosUsecase listTodosUsecase;
  Future<void> execute() async { ... }
}
```

## 悪い例

```dart
@internal
@delegate
final class Bad {
  Bad(this.state);
  MutableStateStream<TodoListScreenState> state; // → delegate_immutable
  Future<void> execute() async {}
}
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/delegate_immutable
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* アノテーション package: `flutter_layered_architecture_annotations`
* 関連 linter rule: `delegate_execute_method`, `delegate_internal`
