import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:meta/meta.dart';
import 'package:screen_feature_todo_list/src/viewmodel/entity/todo_list_screen_entity.dart';
import 'package:screen_feature_todo_list/src/viewmodel/state/todo_list_screen_state.dart';
import 'package:state_stream/state_stream.dart';

TodoListScreenEntity _toEmptyEntity(TodoListScreenState state) {
  return TodoListScreenEntity(
    isLoading: state.isLoading,
    items: const [],
    draftTitle: state.draftTitle,
    canAdd: false,
  );
}

/// Probe: extension 上の on* 以外のメソッド名.
@internal
@viewModel
final class ProbeViewModelBadExtensionMethod {
  final MutableStateStream<TodoListScreenState> state;

  const ProbeViewModelBadExtensionMethod({required this.state});

  StateStream<TodoListScreenEntity> get entity => state.map(_toEmptyEntity);

  Future<void> close() => state.close();
}

/// Probe: on* 以外のメソッド名.
@internal
@viewModel
final class ProbeViewModelBadMethodName {
  final MutableStateStream<TodoListScreenState> state;

  const ProbeViewModelBadMethodName({required this.state});

  StateStream<TodoListScreenEntity> get entity => state.map(_toEmptyEntity);

  Future<void> close() => state.close();

  // expect_lint: viewmodel_on_method_names, stateful_methods_use_delegate
  Future<void> doWork() async {}
}

/// Probe: entity が Freezed ではない（`close()` 経路）.
@internal
@viewModel
final class ProbeViewModelEntityNotFreezed {
  final MutableStateStream<TodoListScreenState> state;

  const ProbeViewModelEntityNotFreezed({required this.state});

  // expect_lint: viewmodel_entity_annotated
  StateStream<List<int>> get entity => throw UnimplementedError();

  Future<void> close() => state.close();
}

/// Probe: entity が state と同じモデル（`_close()` 経路）.
@internal
@viewModel
final class ProbeViewModelEntitySameAsState {
  final MutableStateStream<TodoListScreenState> state;

  const ProbeViewModelEntitySameAsState({required this.state});

  // expect_lint: viewmodel_entity_differs_from_state
  StateStream<TodoListScreenState> get entity => state;

  // ignore: unused_element
  Future<void> _close() => state.close();
}

/// Probe: entity getter 欠落.
@internal
@viewModel
// expect_lint: viewmodel_has_entity_getter
final class ProbeViewModelMissingEntity {
  final MutableStateStream<TodoListScreenState> state;

  const ProbeViewModelMissingEntity({required this.state});

  Future<void> close() => state.close();
}

/// Probe: @internal 欠落.
@viewModel
// expect_lint: viewmodel_internal
final class ProbeViewModelMissingInternal {
  final MutableStateStream<TodoListScreenState> state;

  const ProbeViewModelMissingInternal({required this.state});

  StateStream<TodoListScreenEntity> get entity => state.map(_toEmptyEntity);

  Future<void> close() => state.close();
}

/// Probe: `_close()` は on* 命名例外として許容される.
@internal
@viewModel
final class ProbeViewModelPrivateCloseAllowed {
  final MutableStateStream<TodoListScreenState> state;

  const ProbeViewModelPrivateCloseAllowed({required this.state});

  StateStream<TodoListScreenEntity> get entity => state.map(_toEmptyEntity);

  // ignore: unused_element
  Future<void> _close() => state.close();
}

extension ProbeViewModelBadExtensionMethodActions
    on ProbeViewModelBadExtensionMethod {
  // expect_lint: viewmodel_on_method_names, stateful_methods_use_delegate
  Future<void> save() async {}
}

/// Probe: entity の T が @state のみ（@entity 欠落）.
@internal
@viewModel
final class ProbeViewModelEntityStateAnnotationOnly {
  final MutableStateStream<TodoListScreenState> state;

  const ProbeViewModelEntityStateAnnotationOnly({required this.state});

  // expect_lint: viewmodel_entity_annotated
  StateStream<ProbeStateOnlyModel> get entity => throw UnimplementedError();

  Future<void> close() => state.close();
}

/// Probe 専用の手書きモデル（freezed 生成・part 無し）.
@internal
@state
final class ProbeStateOnlyModel {
  const ProbeStateOnlyModel({required this.value});
  final int value;
}
