---
name: flutter-layered-architecture-linter-rule-delegate-no-usecase-instantiation
description: >-
  Flutter Layered Architecture の linter rule `delegate_no_usecase_instantiation`。
  `@delegate` 内で `@usecase` 型を new しない（コンストラクタ注入する）。
  @usecase の実装・修正、Usecase 設計、診断 `delegate_no_usecase_instantiation` の修正、規約に沿った設計では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# @delegate 内で @usecase を生成しない（`delegate_no_usecase_instantiation`）

`@delegate` 内で `@usecase` 型を new しない（コンストラクタ注入する）。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。
コマンド実行時は、プロジェクト規定のツールチェイン（あれば）に従う。

## いつ使うか

* `delegate_no_usecase_instantiation` 診断の修正・抑制判断
* @usecase の実装・修正、Usecase 設計
* 関連ルール（`delegate_no_nested_delegate`, `usecase_immutable`）と合わせて規約を満たす設計をするとき

## 関連アノテーション

* `@delegate`
* `@usecase`

## 推奨設計

* Usecase は DI で渡し、Delegate は生成責務を持たない
* テスト時に Usecase を差し替えやすくする

## ルールが検証すること

* `@delegate` クラス内で `@usecase` 付き型のインスタンス生成があると WARNING

## 良い例

```dart
@internal
@delegate
final class OnAddTodoDelegate {
  const OnAddTodoDelegate({required this.addTodoUsecase});
  final AddTodoUsecase addTodoUsecase;
  Future<void> execute() => addTodoUsecase.execute(...);
}
```

## 悪い例

```dart
@internal
@delegate
final class Bad {
  const Bad();
  Future<void> execute() async {
    await AddTodoUsecaseImpl(...).execute(...); // → delegate_no_usecase_instantiation
  }
}
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/delegate_no_usecase_instantiation
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* アノテーション package: `flutter_layered_architecture_annotations`
* 関連 linter rule: `delegate_no_nested_delegate`, `usecase_immutable`
