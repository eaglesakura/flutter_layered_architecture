import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';

part 'state_entity_lint_probe.freezed.dart';

/// `@state` / `@entity` 各診断の固定 probe（手書き declaration ファイル）.

// expect_lint: state_entity_freezed
@state
final class ProbeStateEntityNotFreezed {
  const ProbeStateEntityNotFreezed();
}

// expect_lint: state_entity_internal
@state
@freezed
abstract class ProbeStateEntityMissingInternal
    with _$ProbeStateEntityMissingInternal {
  const factory ProbeStateEntityMissingInternal({
    required int value,
  }) = _ProbeStateEntityMissingInternal;
}

// expect_lint: state_entity_exclusive
@internal
@state
@entity
@freezed
abstract class ProbeStateEntityBoth with _$ProbeStateEntityBoth {
  const factory ProbeStateEntityBoth({
    required int value,
  }) = _ProbeStateEntityBoth;
}

// expect_lint: state_entity_required_parameters
@internal
@state
@freezed
abstract class ProbeStateEntityDefaultParameter
    with _$ProbeStateEntityDefaultParameter {
  const factory ProbeStateEntityDefaultParameter({
    @Default(0) int value,
  }) = _ProbeStateEntityDefaultParameter;
}

// expect_lint: state_entity_required_parameters
@internal
@state
@freezed
abstract class ProbeStateEntityDartDefault with _$ProbeStateEntityDartDefault {
  const factory ProbeStateEntityDartDefault({
    int value = 0,
  }) = _ProbeStateEntityDartDefault;
}

// expect_lint: state_entity_no_named_factory
@internal
@state
@freezed
abstract class ProbeStateEntityNamedFactory with _$ProbeStateEntityNamedFactory {
  const factory ProbeStateEntityNamedFactory({
    required int value,
  }) = _ProbeStateEntityNamedFactory;

  factory ProbeStateEntityNamedFactory.zero() =>
      const ProbeStateEntityNamedFactory(value: 0);
}