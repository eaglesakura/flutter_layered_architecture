---
name: flutter-layered-architecture-linter-rule-usecase-method-signature
description: >-
  Flutter Layered Architecture の linter rule `usecase_method_signature`。
  唯一の public インスタンスメソッドは引数あり・非 void 戻り値とする。
  @usecase の実装・修正、Usecase 設計、診断 `usecase_method_signature` の修正、規約に沿った設計では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# @usecase メソッドのシグネチャ（`usecase_method_signature`）

唯一の public インスタンスメソッドは引数あり・非 void 戻り値とする。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。
コマンド実行時は、プロジェクト規定のツールチェイン（あれば）に従う。

## いつ使うか

* `usecase_method_signature` 診断の修正・抑制判断
* @usecase の実装・修正、Usecase 設計
* 関連ルール（`usecase_single_method`, `usecase_immutable`）と合わせて規約を満たす設計をするとき

## 関連アノテーション

* `@usecase`

## 推奨設計

* 入力は Request 型、出力はドメイン結果型で明示する
* 副作用のみでも完了通知や結果オブジェクトを返す
* public メソッドが2つ以上のときは usecase_single_method 側で扱う

## ルールが検証すること

* public メソッドがちょうど1つのとき、パラメータ0または戻り値 void なら WARNING

## 良い例

```dart
@usecase
abstract interface class ListTodosUsecase {
  const ListTodosUsecase();
  Future<List<Todo>> execute(ListTodosRequest request);
}
```

## 悪い例

```dart
@usecase
abstract interface class Bad {
  const Bad();
  void execute() {} // → usecase_method_signature
}
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/usecase_method_signature
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* アノテーション package: `flutter_layered_architecture_annotations`
* 関連 linter rule: `usecase_single_method`, `usecase_immutable`
