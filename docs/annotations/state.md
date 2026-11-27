# @state

Marks a Freezed state-holding model that may be the type argument `T` of `MutableStateStream<T>`, so lint can validate gate A structure and gate B references from `@stateful` / `@viewModel`.

## Details

DO attach `@state` to the Freezed model used as the root `T` of `MutableStateStream<T>`. Companion annotations `@internal` (`package:meta`) and `@freezed` / `@Freezed()` (`freezed_annotation`) are required. Do not also attach `@entity` to the same type.

Gate A structure rules:

* Every parameter of the primary data factory must be explicitly `required`
* `@Default` and Dart default parameter values are forbidden
* Named factories (for example `.initial()`) are WARNING; callers must pass all arguments at the call site

Nesting `@state` on nested types is optional; gate B only requires the root `T`.

Severity of related lint checks: WARNING.

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

Also import `package:meta/meta.dart` and `package:freezed_annotation/freezed_annotation.dart`.

Attach to: type. Do not attach to a barrel `library`.

## Related linter rules

* [state_entity_freezed](../linter-rules/state_entity_freezed.md)
* [state_entity_internal](../linter-rules/state_entity_internal.md)
* [state_entity_exclusive](../linter-rules/state_entity_exclusive.md)
* [state_entity_required_parameters](../linter-rules/state_entity_required_parameters.md)
* [state_entity_no_named_factory](../linter-rules/state_entity_no_named_factory.md)
* [stateful_mutable_state_stream_state](../linter-rules/stateful_mutable_state_stream_state.md)
