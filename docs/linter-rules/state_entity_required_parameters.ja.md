# state_entity_required_parameters

`@state` / `@entity` の主データ factory パラメータはすべて `required` とし、`@Default` や Dart デフォルト引数を使わない。

## Details

DO `@state` / `@entity` 型の主データ factory（名前なし `factory`）の全パラメータに `required` を明示する。`@Default` と Dart のデフォルト引数は使わない。違反パラメータごとに報告する。ゲート A（注釈付き型自身の構造）である。Severity は WARNING である。

関連アノテーション: `@state`, `@entity`。

BAD:

```dart
@internal
@state
@freezed
abstract class Bad with _$Bad {
  const factory Bad({
    @Default(0) int value,
  }) = _Bad;
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
// ignore: flutter_layered_architecture_lint/state_entity_required_parameters
```
