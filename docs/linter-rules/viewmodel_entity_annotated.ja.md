# viewmodel_entity_annotated

`@viewModel` の `entity` における `StateStream<T>` の型引数 `T` は `@entity` 付き class である。

## Details

DO `StateStream<T> get entity` のモデル型 `T` に `@entity` を付ける。これはゲート B であり、ルート型引数に `@entity` があることだけを検査する。Freezed 形状、`@internal`、factory 制約はゲート A（`state_entity_*` ルール群）が `@entity` 型そのものに対して検査する。

Severity は WARNING である。

関連アノテーション: `@viewModel`、`@entity`。関連ルール: `viewmodel_has_entity_getter`、`stateful_mutable_state_stream_state`。entity と state は別型にする（`viewmodel_entity_differs_from_state`）。

BAD:

```dart
@freezed
abstract class TodoListScreenEntity with _$TodoListScreenEntity {
  const factory TodoListScreenEntity({required bool isLoading}) =
      _TodoListScreenEntity;
}

@internal
@viewModel
final class Bad {
  StateStream<TodoListScreenEntity> get entity => throw UnimplementedError();
}
```

GOOD:

```dart
@internal
@entity
@freezed
abstract class TodoListScreenEntity with _$TodoListScreenEntity {
  const factory TodoListScreenEntity({
    required bool isLoading,
    required List<TodoListItemEntity> items,
    required String draftTitle,
    required bool canAdd,
  }) = _TodoListScreenEntity;
}

StateStream<TodoListScreenEntity> get entity =>
    state.map(stateToEntityDelegate.execute);
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
// ignore: flutter_layered_architecture_lint/viewmodel_entity_annotated
```
