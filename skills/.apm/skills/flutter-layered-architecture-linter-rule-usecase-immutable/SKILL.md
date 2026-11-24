---
name: flutter-layered-architecture-linter-rule-usecase-immutable
description: >-
  Flutter Layered Architecture の linter rule `usecase_immutable`。
  `@usecase` は final フィールドと const コンストラクタを持つ。
  @usecase の実装・修正、Usecase 設計、診断 `usecase_immutable` の修正、規約に沿った設計では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# @usecase のイミュータブル構造（`usecase_immutable`）

`@usecase` は final フィールドと const コンストラクタを持つ。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。
コマンド実行時は、プロジェクト規定のツールチェイン（あれば）に従う。

## いつ使うか

* `usecase_immutable` 診断の修正・抑制判断
* @usecase の実装・修正、Usecase 設計
* 関連ルール（`usecase_single_method`, `usecase_method_signature`）と合わせて規約を満たす設計をするとき

## 関連アノテーション

* `@usecase`

## 推奨設計

* 依存はコンストラクタ注入し、フィールドはすべて final / const
* 実装クラスも const 生成可能にしてテストしやすくする

## ルールが検証すること

* フィールドがすべて final/const でない、または const コンストラクタが無いと WARNING

## 良い例

```dart
@usecase
final class AddTodoUsecaseImpl {
  const AddTodoUsecaseImpl({required this.repository});
  final TodoRepository repository;
  Future<Todo> execute(AddTodoRequest request) => repository.add(request);
}
```

## 悪い例

```dart
@usecase
final class Bad {
  Bad(this.repository); // non-const
  TodoRepository repository; // non-final → usecase_immutable
  Future<Todo> execute(AddTodoRequest request) => repository.add(request);
}
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/usecase_immutable
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* アノテーション package: `flutter_layered_architecture_annotations`
* 関連 linter rule: `usecase_single_method`, `usecase_method_signature`
