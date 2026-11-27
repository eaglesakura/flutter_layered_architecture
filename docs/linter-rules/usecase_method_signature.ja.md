# usecase_method_signature

`@usecase` の唯一の public インスタンスメソッドは、引数あり・非 void 戻り値とする。

## Details

DO `@usecase` 型の唯一の public インスタンスメソッドに、1 つ以上のパラメータと非 void の戻り値型を付ける。入力は Request 型、出力はドメイン結果型で明示する。

本ルールは public インスタンスメソッドがちょうど 1 つのときだけ検査する。2 つ以上は `usecase_single_method` が扱う。Severity は WARNING である。

関連アノテーション: `@usecase`。

BAD:

```dart
@usecase
abstract interface class Bad {
  const Bad();

  void execute() {}
}
```

GOOD:

```dart
@usecase
abstract interface class ListTodosUsecase {
  const ListTodosUsecase();

  Future<List<Todo>> execute(ListTodosRequest request);
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
// ignore: flutter_layered_architecture_lint/usecase_method_signature
```
