# state_entity_internal

`@state` / `@entity` 型には `@internal` を併記する。

## Details

DO `@state` / `@entity` 型に `@internal` を付ける。注釈付き型自身の構造を検査する。Severity は WARNING である。

関連アノテーション: `@state`, `@entity`。

BAD:

```dart
@state
@freezed
abstract class Bad with _$Bad {
  const factory Bad({required int value}) = _Bad;
}
```

GOOD:

```dart
@internal
@state
@freezed
abstract class TodoListScreenState with _$TodoListScreenState {
  const factory TodoListScreenState({
    required bool isLoading,
    required List<Todo> todos,
    required String draftTitle,
  }) = _TodoListScreenState;
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
// ignore: flutter_layered_architecture_lint/state_entity_internal
```
