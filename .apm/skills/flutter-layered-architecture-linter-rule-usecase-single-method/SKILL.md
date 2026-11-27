---
name: flutter-layered-architecture-linter-rule-usecase-single-method
description: >-
  Flutter Layered Architecture の linter rule `usecase_single_method`。
  `@usecase` 型の public インスタンスメソッドを2つ以上にしない。
  @usecase の実装・修正、Usecase 設計、診断 `usecase_single_method` の修正、規約に沿った設計では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# @usecase は public メソッド1つまで（`usecase_single_method`）

`@usecase` 型の public インスタンスメソッドを2つ以上にしない。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。
コマンド実行時は、プロジェクト規定のツールチェイン（あれば）に従う。

## いつ使うか

* `usecase_single_method` 診断の修正・抑制判断
* @usecase の実装・修正、Usecase 設計
* 関連ルール（`usecase_method_signature`, `usecase_immutable`）と合わせて規約を満たす設計をするとき

## 関連アノテーション

* `@usecase`

## 推奨設計

* Usecase は「1ユースケース = 1操作」に保つ
* 複数操作が必要なら Usecase を分割する
* private メソッド（`_`）は件数に含めない

## ルールが検証すること

* public インスタンスメソッドが2つ以上なら WARNING

## 良い例

```dart
@usecase
abstract interface class AddTodoUsecase {
  const AddTodoUsecase();
  Future<Todo> execute(AddTodoRequest request);
}
```

## 悪い例

```dart
@usecase
abstract interface class TodoUsecase {
  Future<Todo> add(AddTodoRequest request);
  Future<void> delete(String id); // → usecase_single_method
}
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/usecase_single_method
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* アノテーション package: `flutter_layered_architecture_annotations`
* 関連 linter rule: `usecase_method_signature`, `usecase_immutable`
