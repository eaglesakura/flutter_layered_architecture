# state_entity_no_named_factory

`@state` / `@entity` 型に named factory（例: `.initial()`）を定義しない。

## Details

DO `@state` / `@entity` 型で named factory（`factory Foo.bar()`）を定義しない。初期値の省略はせず、呼び出し側で主 factory の全引数を明示する。注釈付き型自身の構造を検査する。Severity は WARNING である。

関連アノテーション: `@state`, `@entity`。

BAD:

```dart
@internal
@state
@freezed
abstract class Bad with _$Bad {
  const factory Bad({required int value}) = _Bad;

  factory Bad.zero() => const Bad(value: 0);
}
```

GOOD:

```dart
const TodoListScreenState(
  isLoading: true,
  todos: [],
  draftTitle: '',
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
// ignore: flutter_layered_architecture_lint/state_entity_no_named_factory
```
