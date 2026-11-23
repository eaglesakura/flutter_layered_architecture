import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:meta/meta.dart';

/// Probe: 内部で Usecase を生成する.
@internal
@delegate
final class ProbeDelegateCreatesUsecase {
  const ProbeDelegateCreatesUsecase();

  void execute() {
    // expect_lint: delegate_no_usecase_instantiation
    const ProbeUsecaseForDelegate();
  }
}

/// Probe: @internal 欠落.
@delegate
// expect_lint: delegate_internal
final class ProbeDelegateMissingInternal {
  const ProbeDelegateMissingInternal();

  void execute() {}
}

/// Probe: non-final フィールドと非 const コンストラクタ.
@internal
@delegate
// expect_lint: delegate_immutable
final class ProbeDelegateMutable {
  int value;

  ProbeDelegateMutable(this.value);

  void execute() {}
}

/// Probe: execute 以外のメソッド / 複数メソッド.
@internal
@delegate
// expect_lint: delegate_execute_method
final class ProbeDelegateWrongMethod {
  const ProbeDelegateWrongMethod();

  void run() {}
}

/// Nested Delegate 検査用の内側 Delegate.
@internal
@delegate
final class ProbeInnerDelegate {
  const ProbeInnerDelegate();

  void execute() {}
}

/// Probe: 内部で別 Delegate を生成する.
@internal
@delegate
final class ProbeNestedDelegateNew {
  const ProbeNestedDelegateNew();

  void execute() {
    // expect_lint: delegate_no_nested_delegate
    const ProbeInnerDelegate();
  }
}

/// Probe: コンストラクタで別 Delegate を受け取る.
@internal
@delegate
final class ProbeNestedDelegateParam {
  final ProbeInnerDelegate inner;

  // expect_lint: delegate_no_nested_delegate
  const ProbeNestedDelegateParam(this.inner);

  void execute() {}
}

/// Usecase 生成検査用.
@usecase
final class ProbeUsecaseForDelegate {
  const ProbeUsecaseForDelegate();

  int execute(int request) => request;
}
