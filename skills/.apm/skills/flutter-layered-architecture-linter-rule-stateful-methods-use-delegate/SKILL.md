---
name: flutter-layered-architecture-linter-rule-stateful-methods-use-delegate
description: >-
  Flutter Layered Architecture の linter rule `stateful_methods_use_delegate`。
  業務処理は `@delegate` の `execute` に委譲する（close のみ例外）。
  @delegate の実装・修正、処理切り出し、診断 `stateful_methods_use_delegate` の修正、規約に沿った設計では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# @stateful メソッドは @delegate へ委譲（`stateful_methods_use_delegate`）

業務処理は `@delegate` の `execute` に委譲する（close のみ例外）。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。
コマンド実行時は、プロジェクト規定のツールチェイン（あれば）に従う。

## いつ使うか

* `stateful_methods_use_delegate` 診断の修正・抑制判断
* @delegate の実装・修正、処理切り出し
* 関連ルール（`delegate_execute_method`, `viewmodel_on_method_names`）と合わせて規約を満たす設計をするとき

## 関連アノテーション

* `@stateful`
* `@viewModel`
* `@delegate`

## 推奨設計

* ViewModel / Stateful 本体は薄いファサードにし、処理は Delegate に切り出す
* `close` / `_close` で MutableStateStream.close だけ行うメソッドは例外

## ルールが検証すること

* インスタンスメソッドが Delegate.execute 呼び出しになっていないと WARNING（close 例外を除く）

## 良い例

```dart
@viewModel
final class TodoListScreenViewModel {
  ...
  Future<void> onAddTodo() => OnAddTodoDelegate(...).execute();
  Future<void> close() => state.close();
}
```

## 悪い例

```dart
@viewModel
final class Bad {
  Future<void> onAddTodo() async {
    await state.updateWithLock(...); // Delegate 無し → stateful_methods_use_delegate
  }
}
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/stateful_methods_use_delegate
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* アノテーション package: `flutter_layered_architecture_annotations`
* 関連 linter rule: `delegate_execute_method`, `viewmodel_on_method_names`
