import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:screen_feature_todo_list/src/viewmodel/state/todo_list_screen_state.dart';
import 'package:state_stream/state_stream.dart';

/// Probe: メソッドが @delegate へ委譲されていない.
@stateful
final class ProbeStatefulMethodWithoutDelegate {
  final MutableStateStream<TodoListScreenState> state;

  const ProbeStatefulMethodWithoutDelegate({required this.state});

  Future<void> close() => state.close();

  // expect_lint: stateful_methods_use_delegate
  Future<void> doWork() async {}
}

/// Probe: close() 未呼び出し.
@stateful
// expect_lint: stateful_closes_mutable_state_stream
final class ProbeStatefulMissingClose {
  final MutableStateStream<TodoListScreenState> state;

  const ProbeStatefulMissingClose({required this.state});
}

/// Probe: MutableStateStream フィールド欠落.
@stateful
// expect_lint: stateful_has_mutable_state_stream
final class ProbeStatefulMissingStream {
  const ProbeStatefulMissingStream();
}

/// Probe: non-final フィールドと非 const コンストラクタ.
@stateful
// expect_lint: stateful_immutable
final class ProbeStatefulMutable {
  MutableStateStream<TodoListScreenState> state;

  ProbeStatefulMutable(this.state);

  Future<void> close() => state.close();
}

/// Probe: MutableStateStream の型引数が Freezed ではない.
@stateful
final class ProbeStatefulNonFreezedState {
  // expect_lint: stateful_mutable_state_stream_freezed
  final MutableStateStream<List<int>> state;

  const ProbeStatefulNonFreezedState({required this.state});

  Future<void> close() => state.close();
}
