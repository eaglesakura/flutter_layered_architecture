# @entity

`StateStream<T> get entity` の型引数 `T` になりうる画面表示モデル型を示し、ゲート A の構造とゲート B の ViewModel 参照を lint が検証できるようにするアノテーションである。

## Details

DO `StateStream<T> get entity` のルート `T` として使う Freezed モデルに `@entity` を付与する。併記として `@internal`（`package:meta`）と `@freezed` / `@Freezed()`（`freezed_annotation`）が必須である。同一型に `@state` を付けてはならない。

ゲート A の構築規約は `@state` と同じである。

* 主データ factory の全パラメータは `required` 明示
* `@Default` および Dart のデフォルト引数は禁止
* named factory の定義は WARNING

ネストした表示モデルへの `@entity` は任意である。ゲート B はルートの `entity` の `T` のみを見る。`entity` のモデル型は `MutableStateStream` の状態モデル型と異なっていなければならない。

関連 lint の Severity: WARNING。

BAD:

```dart
@entity
final class PlainEntity {}
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
  }) = _TodoListScreenEntity;
}
```

## Usage

Import:

```dart
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
```

`package:meta/meta.dart` と `package:freezed_annotation/freezed_annotation.dart` も import する。

付与先: 型。バレル `library` には付けない。

## Related linter rules

* [state_entity_freezed](../linter-rules/state_entity_freezed.ja.md)
* [state_entity_internal](../linter-rules/state_entity_internal.ja.md)
* [state_entity_exclusive](../linter-rules/state_entity_exclusive.ja.md)
* [state_entity_required_parameters](../linter-rules/state_entity_required_parameters.ja.md)
* [state_entity_no_named_factory](../linter-rules/state_entity_no_named_factory.ja.md)
* [viewmodel_entity_annotated](../linter-rules/viewmodel_entity_annotated.ja.md)
* [viewmodel_entity_differs_from_state](../linter-rules/viewmodel_entity_differs_from_state.ja.md)
