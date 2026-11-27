---
name: flutter-layered-architecture-linter-rule-delegate-execute-method
description: >-
  Flutter Layered Architecture の linter rule `delegate_execute_method`。
  `@delegate` 型のインスタンスメソッドはちょうど1つで名前は `execute`。
  @delegate の実装・修正、処理切り出し、診断 `delegate_execute_method` の修正、規約に沿った設計では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# @delegate は execute のみ（`delegate_execute_method`）

`@delegate` 型のインスタンスメソッドはちょうど1つで名前は `execute`。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。
コマンド実行時は、プロジェクト規定のツールチェイン（あれば）に従う。

## いつ使うか

* `delegate_execute_method` 診断の修正・抑制判断
* @delegate の実装・修正、処理切り出し
* 関連ルール（`delegate_immutable`, `delegate_internal`, `stateful_methods_use_delegate`）と合わせて規約を満たす設計をするとき

## 関連アノテーション

* `@delegate`
* `@internal`

## 推奨設計

* Delegate は単一処理ユニット。入口は常に `execute`
* ViewModel / Stateful から業務処理を切り出す受け皿

## ルールが検証すること

* インスタンスメソッドが1つでない、または名前が execute でないと WARNING

## 良い例

```dart
@internal
@delegate
final class OnAddTodoDelegate {
  const OnAddTodoDelegate({required this.state});
  final MutableStateStream<TodoListScreenState> state;
  Future<void> execute() async { ... }
}
```

## 悪い例

```dart
@internal
@delegate
final class Bad {
  const Bad();
  Future<void> run() async {} // → delegate_execute_method
}
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/delegate_execute_method
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* アノテーション package: `flutter_layered_architecture_annotations`
* 関連 linter rule: `delegate_immutable`, `delegate_internal`, `stateful_methods_use_delegate`
