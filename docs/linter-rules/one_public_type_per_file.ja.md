# one_public_type_per_file

1 つの Dart ファイルに public な名前付き型（`class` / `enum` / `mixin` / 名前付き `extension` / `extension type`）を 2 つ以上置かない。

## Details

DO 各 Dart ファイルの public な名前付き型を高々 1 つにする。複数型が必要ならファイルを分割するか、ヘルパーを private（`_` 始まり）にする。

private 型と `typedef` は件数に含めない。`part of` ファイルと `test/` 配下は対象外である。public 型が 0 個のファイルは許可される。Severity は WARNING である。

関連アノテーションはない（ファイルレイアウト規約）。

BAD:

```dart
// models.dart
final class AddTodoRequest {
  const AddTodoRequest({required this.title});
  final String title;
}

final class ListTodosRequest {
  const ListTodosRequest();
}
```

GOOD:

```dart
// add_todo_request.dart
final class AddTodoRequest {
  const AddTodoRequest({required this.title});
  final String title;
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
// ignore: flutter_layered_architecture_lint/one_public_type_per_file
```
