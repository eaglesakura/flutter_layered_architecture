/// Probe: 未 export の公開 typedef も対象.
// expect_lint: unexported_public_must_be_internal
typedef ProbeUnexportedCallback = void Function();
