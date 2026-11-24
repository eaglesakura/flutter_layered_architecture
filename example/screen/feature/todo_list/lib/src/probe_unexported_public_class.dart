/// Probe: バレル未 export の公開 class は `@internal` 必須.
// expect_lint: unexported_public_must_be_internal
final class ProbeUnexportedPublicClass {
  /// Creates a [ProbeUnexportedPublicClass].
  const ProbeUnexportedPublicClass();
}
