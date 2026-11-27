# @entity

Marks a Freezed presentation model that may be the type argument `T` of `StateStream<T> get entity`, so lint can validate gate A structure and gate B ViewModel references.

## Details

DO attach `@entity` to the Freezed model used as the root `T` of `StateStream<T> get entity`. Companion annotations `@internal` (`package:meta`) and `@freezed` / `@Freezed()` (`freezed_annotation`) are required. Do not also attach `@state` to the same type.

Gate A structure rules are the same as `@state`:

* Every parameter of the primary data factory must be explicitly `required`
* `@Default` and Dart default parameter values are forbidden
* Named factories are WARNING

Nesting `@entity` on nested presentation models is optional; gate B only requires the root `entity` `T`. The `entity` model type must differ from the `MutableStateStream` state model type.

Severity of related lint checks: WARNING.

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

Also import `package:meta/meta.dart` and `package:freezed_annotation/freezed_annotation.dart`.

Attach to: type. Do not attach to a barrel `library`.

## Related linter rules

* [state_entity_freezed](../linter-rules/state_entity_freezed.md)
* [state_entity_internal](../linter-rules/state_entity_internal.md)
* [state_entity_exclusive](../linter-rules/state_entity_exclusive.md)
* [state_entity_required_parameters](../linter-rules/state_entity_required_parameters.md)
* [state_entity_no_named_factory](../linter-rules/state_entity_no_named_factory.md)
* [viewmodel_entity_annotated](../linter-rules/viewmodel_entity_annotated.md)
* [viewmodel_entity_differs_from_state](../linter-rules/viewmodel_entity_differs_from_state.md)
