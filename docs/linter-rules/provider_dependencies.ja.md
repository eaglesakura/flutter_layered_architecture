# provider_dependencies

create コールバック直下で `ref.watch(X)` した参照は、同じ Provider の `dependencies` に字面一致で列挙する。

## Details

DO `ref.watch` した各参照を `dependencies: [...]` に含める（ソース字面の trim 一致）。

DO NOT `dependencies` 省略・`[]`・一部欠落。`ref.watch` が無い宣言（IF stub、`stateBy` のみ等）は検査しない。余分なエントリは許容。Severity は WARNING。複数欠落は各 `ref.watch` 位置に 1 件。

BAD:

```dart
static final provider = Provider<AddTodoUsecaseImpl>(
  (ref) => AddTodoUsecaseImpl(ref.watch(TodoRepository.provider)),
);
```

GOOD:

```dart
static final provider = Provider<AddTodoUsecaseImpl>(
  (ref) => AddTodoUsecaseImpl(ref.watch(TodoRepository.provider)),
  dependencies: [TodoRepository.provider],
);
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
// ignore: flutter_layered_architecture_lint/provider_dependencies
```