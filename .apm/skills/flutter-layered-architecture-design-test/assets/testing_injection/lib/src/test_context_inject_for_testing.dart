import "package:armyknife_test_context/armyknife_test_context.dart";
import "package:data_repository_todo/data_repository_todo.dart";
import "package:data_repository_todo_impl/data_repository_todo_impl.dart";
import "package:foundation_dependency_injection/foundation_dependency_injection.dart";
import "package:testing_core/testing_core.dart";
import "package:usecase_todo/usecase_todo.dart";
import "package:usecase_todo_impl/usecase_todo_impl.dart";

part "test_context_inject_for_testing.data.dart";
part "test_context_inject_for_testing.usecase.dart";

/// [TestContext]向けDI拡張。
///
/// Example:
/// ```dart
/// await testContext.injectForTesting();
/// ```
extension TestContextInjectionExtensions on TestContext {
  /// Unit Test向け依存を一括注入する。
  ///
  /// NOTE.
  /// DIとDartの仕様上、この処理利用時は全実装モジュールへの暗黙参照が発生する。
  ///
  /// NOTE.
  /// Data / Usecase は各 part へ分割する。
  /// app の本番 `inject()` と非正規化で二重管理し、`app` へは依存しない。
  Future<void> injectForTesting() async {
    // Infra が必要ならここで Testing*Injection.inject(refBuilder) を呼ぶ。
    await _injectForTestingData(refBuilder);
    await _injectForTestingUsecase(refBuilder);
  }
}
