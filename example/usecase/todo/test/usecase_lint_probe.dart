import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';

/// Probe: too many instance methods.
@usecase
// expect_lint: usecase_single_method
final class ProbeTooManyMethods {
  const ProbeTooManyMethods();

  void a() {}

  void b() {}
}

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
  ProbeMutable(this.value);

  int value;

  int execute(int request) => request;
}
