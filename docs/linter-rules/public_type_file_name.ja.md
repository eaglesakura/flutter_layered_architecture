# public_type_file_name

唯一の public 型名を `lower_snake_case` にしたファイル名にする。

`keywords` を含む `layered_architecture.yaml` のスキーマは [layered_architecture_yaml.ja.md](../layered_architecture_yaml.ja.md) を参照する。

## Details

DO ファイル内に唯一の public な名前付き型があるとき、ファイル名をその型名の `lower_snake_case` にする。public 型が 0 個または 2 個以上のときは本ルールは報告しない（件数は `one_public_type_per_file` が扱う）。

最寄りの `layered_architecture.yaml` で、CamelCase セグメントをファイル名用トークンへ置換する keywords を任意設定できる:

```yaml
rules:
  public_type_file_name:
    keywords:
      UseCase: usecase
      ViewModel: viewmodel
```

`UseCase: usecase` があるとき、型 `AddTodoUseCase` は `add_todo_usecase.dart` を期待する（未設定なら `add_todo_use_case.dart`）。キーワードは YAML 記載順で適用され、先勝ちである。マッチは大文字小文字を厳密に見る（`UseCase` 設定は型セグメント `Usecase` に効かない）。`rules` / `keywords` が無い、または空なら従来どおりの PascalCase→snake 変換のみである。

`part of` ファイルと `test/` 配下は対象外である。Severity は WARNING である。

関連アノテーションはない（ファイルレイアウト規約）。

BAD:

```dart
// usecase.dart
@usecase
abstract interface class AddTodoUsecase {
  const AddTodoUsecase();

  Future<Todo> execute(AddTodoRequest request);
}
```

GOOD:

```dart
// add_todo_usecase.dart
@usecase
abstract interface class AddTodoUsecase {
  const AddTodoUsecase();

  Future<Todo> execute(AddTodoRequest request);
}
```

`keywords: UseCase: usecase` がある場合:

```dart
// add_todo_usecase.dart
@usecase
abstract interface class AddTodoUseCase {
  const AddTodoUseCase();

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
// ignore: flutter_layered_architecture_lint/public_type_file_name
```
