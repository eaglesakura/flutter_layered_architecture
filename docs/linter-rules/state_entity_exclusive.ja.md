# state_entity_exclusive

同一型に `@state` と `@entity` を同時付与しない。

## Details

DO 同一型に `@state` と `@entity` のどちらか一方のみを付ける。State と Entity を別型に保つための制約である。ゲート A（注釈付き型自身の構造）である。Severity は WARNING である。

関連アノテーション: `@state`, `@entity`。

BAD:

```dart
@internal
@state
@entity
@freezed
abstract class Both with _$Both {
  const factory Both({required int value}) = _Both;
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

@internal
@entity
@freezed
abstract class TodoListScreenEntity with _$TodoListScreenEntity {
  const factory TodoListScreenEntity({
    required bool isLoading,
    required List<Todo> todos,
    required String draftTitle,
  }) = _TodoListScreenEntity;
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
// ignore: flutter_layered_architecture_lint/state_entity_exclusive
```
