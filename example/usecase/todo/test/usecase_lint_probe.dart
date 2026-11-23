import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';

/// Probe: missing parameters / void return.
@usecase
final class ProbeBadSignature {
  const ProbeBadSignature();

  // expect_lint: usecase_method_signature
  void execute() {}
}

/// Probe: non-final field and missing const constructor.
@usecase
// expect_lint: usecase_immutable
final class ProbeMutable {
  int value;

  ProbeMutable(this.value);

  int execute(int request) => request;
}

/// Probe: public は1つで private は許容.
@usecase
final class ProbePrivateHelperAllowed {
  const ProbePrivateHelperAllowed();

  int execute(int request) => _helper(request);

  int _helper(int value) => value;
}

/// Probe: public インスタンスメソッドが2つ以上.
@usecase
// expect_lint: usecase_single_method
final class ProbeTooManyMethods {
  const ProbeTooManyMethods();

  void a() {}

  void b() {}
}
