# @state

`MutableStateStream<T>` の型引数 `T` になりうる状態保持モデル型を示し、型自身の構造と `@stateful` / `@viewModel` からの参照を lint が検証できるようにするアノテーションである。

## Details

DO `MutableStateStream<T>` のルート `T` として使う Freezed モデルに `@state` を付与する。併記として `@internal`（`package:meta`）と `@freezed` / `@Freezed()`（`freezed_annotation`）が必須である。同一型に `@entity` を付けてはならない。

構築規約:

* 主データ factory の全パラメータは `required` 明示
* `@Default` および Dart のデフォルト引数は禁止
* named factory（例: `.initial()`）の定義は WARNING（呼び出し側で全引数を明示する）

ネストした型への `@state` は任意である。参照元の検査はルートの `T` のみを見る。

関連 lint の Severity: WARNING。

BAD:

```dart
@state
@freezed
abstract class Bad with _$Bad {
  const factory Bad({@Default(0) int x}) = _Bad;
  factory Bad.initial() => const Bad(x: 0);
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
* [stateful_mutable_state_stream_state](../linter-rules/stateful_mutable_state_stream_state.ja.md)
