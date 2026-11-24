import 'package:meta/meta.dart';

/// Probe: `@internal` があれば未 export でも許容.
@internal
final class ProbeUnexportedInternalClass {
  /// Creates a [ProbeUnexportedInternalClass].
  const ProbeUnexportedInternalClass();
}

/// Probe: private は `@internal` 不要.
// ignore: unused_element
final class _ProbePrivateClass {
  const _ProbePrivateClass();
}
