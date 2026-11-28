# provider_static_final

検査対象の Provider 宣言を、class 系型の `static final` メンバに置く。トップレベルや非適合宿主・非 `static final` は WARNING。

## Details

DO Provider / FutureProvider / StreamProvider / StateNotifierProvider / NotifierProvider / AsyncNotifierProvider / StreamNotifierProvider / StateStreamProvider（および `.autoDispose` / `.stateBy`）を、`class` / `final class` / `abstract class` / `abstract interface class` / `mixin class` の `static final` に所属させる。

DO NOT ライブラリのトップレベルに置く。`mixin` / `enum` / `extension` / `extension type` のメンバにも置かない。メソッド内ローカル変数は対象外。Severity は WARNING。

BAD:

```dart
final todoRepositoryProvider = Provider<TodoRepository>(
  (ref) => throw UnimplementedError(),
);
```

GOOD:

```dart
abstract interface class TodoRepository {
  static final provider = Provider<TodoRepository>(
    (ref) => throw UnimplementedError('TodoRepository is not bound'),
  );
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
// ignore: flutter_layered_architecture_lint/provider_static_final
```