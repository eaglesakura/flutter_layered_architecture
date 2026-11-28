# provider_ref_watch

Provider 生成コールバック直下では `ref.read` を使わず `ref.watch` を使う。

## Details

DO 依存取得は create コールバック直下で `ref.watch(...)`。

DO NOT 同直下で `ref.read(...)`。ネスト関数内・Widget 側・Provider 生成外は対象外。`.stateBy` のみの宣言は create 無しのため対象外。Severity は WARNING。

BAD:

```dart
static final provider = Provider<AddTodoUsecaseImpl>(
  (ref) => AddTodoUsecaseImpl(ref.read(TodoRepository.provider)),
  dependencies: [TodoRepository.provider],
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
// ignore: flutter_layered_architecture_lint/provider_ref_watch
```