import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:state_stream/state_stream.dart';

/// Probe: close() 未呼び出し.
@stateful
// expect_lint: stateful_closes_mutable_state_stream
final class ProbeStatefulMissingClose {
  final MutableStateStream<int> state;

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
  MutableStateStream<int> state;

  ProbeStatefulMutable(this.state);

  Future<void> close() => state.close();
}
