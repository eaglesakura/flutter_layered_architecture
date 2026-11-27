# usecase_immutable

`@usecase` 型は final フィールドと const コンストラクタを持つ。

## Details

DO `@usecase` 型のフィールドをすべて `final` または `const` にし、`const` コンストラクタを 1 つ以上宣言する。依存はコンストラクタ注入とし、不変かつテストしやすい構造にする。

Severity は WARNING である。

関連アノテーション: `@usecase`。

BAD:

```dart
@usecase
final class Bad {
  Bad(this.repository);
  TodoRepository repository;

  Future<Todo> execute(AddTodoRequest request) => repository.add(request);
}
```

GOOD:

```dart
@usecase
final class AddTodoUsecaseImpl {
  const AddTodoUsecaseImpl({required this.repository});

  final TodoRepository repository;

  Future<Todo> execute(AddTodoRequest request) => repository.add(request);
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
// ignore: flutter_layered_architecture_lint/usecase_immutable
```
