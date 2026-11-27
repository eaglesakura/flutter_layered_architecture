---
name: flutter-layered-architecture-linter-rule-delegate-no-nested-delegate
description: >-
  Flutter Layered Architecture の linter rule `delegate_no_nested_delegate`。
  `@delegate` が別の `@delegate` を受け取ったり生成したりしない。
  @delegate の実装・修正、処理切り出し、診断 `delegate_no_nested_delegate` の修正、規約に沿った設計では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# @delegate の入れ子禁止（`delegate_no_nested_delegate`）

`@delegate` が別の `@delegate` を受け取ったり生成したりしない。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。
コマンド実行時は、プロジェクト規定のツールチェイン（あれば）に従う。

## いつ使うか

* `delegate_no_nested_delegate` 診断の修正・抑制判断
* @delegate の実装・修正、処理切り出し
* 関連ルール（`delegate_execute_method`, `delegate_no_usecase_instantiation`）と合わせて規約を満たす設計をするとき

## 関連アノテーション

* `@delegate`

## 推奨設計

* Delegate 同士の連鎖は依存グラフを複雑にする
* 共通処理は Usecase / ヘルパーへ寄せ、Delegate は画面操作単位に保つ

## ルールが検証すること

* コンストラクタ引数の型が `@delegate` 付き、または内部で `@delegate` 型を new すると WARNING

## 良い例

```dart
@internal
@delegate
final class OnAddTodoDelegate {
  const OnAddTodoDelegate({required this.addTodoUsecase});
  final AddTodoUsecase addTodoUsecase; // @usecase は受け取り可
  Future<void> execute() async { ... }
}
```

## 悪い例

```dart
@internal
@delegate
final class Outer {
  const Outer({required this.inner});
  final OtherDelegate inner; // @delegate → delegate_no_nested_delegate
  Future<void> execute() async {}
}
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/delegate_no_nested_delegate
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* アノテーション package: `flutter_layered_architecture_annotations`
* 関連 linter rule: `delegate_execute_method`, `delegate_no_usecase_instantiation`
