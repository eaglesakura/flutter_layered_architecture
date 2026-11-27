# usecase_single_method

`@usecase` 型の public インスタンスメソッドを 2 つ以上にしない。

## Details

DO `@usecase` 型の public インスタンスメソッドを高々 1 つにする。Usecase は 1 操作を表す。複数の公開入口が必要なら Usecase を分割する。

private メソッド（`_` 始まり）は件数に含めない。Severity は WARNING である。

関連アノテーション: `@usecase`。

BAD:

```dart
@usecase
abstract interface class TodoUsecase {
  Future<Todo> add(AddTodoRequest request);
  Future<void> delete(String id);
}
```

GOOD:

```dart
@usecase
abstract interface class AddTodoUsecase {
  const AddTodoUsecase();

  Future<Todo> execute(AddTodoRequest request);
}
```

## Enable

本ルールは `flutter_layered_architecture_lint` analyzer プラグインに含まれる。ワークスペースルートの `analysis_options.yaml` でプラグインを有効化する:

```yaml
plugins:
  flutter_layered_architecture_lint:
    path: packages/lint
```

Dart 3.14+（Flutter 3.50+）が必要である。`plugins:` を変更したら Dart Analysis Server を再起動する。

## Suppress

```dart
// ignore: flutter_layered_architecture_lint/usecase_single_method
```
