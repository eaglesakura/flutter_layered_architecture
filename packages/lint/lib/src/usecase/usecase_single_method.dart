import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/usecase/usecase_checkers.dart';

/// `@usecase` 型の public インスタンスメソッドが2つ以上ないことを検証する Lint.
///
/// public メソッドが2つ以上のとき、型名位置に WARNING を出す.
/// private メソッド（`_` 始まり）は件数に含めない.
///
/// Example:
/// ```dart
/// // @usecase
/// // final class Bad {
/// //   const Bad();
/// //   void a() {}
/// //   void b() {}
/// // }
/// // → usecase_single_method
/// ```
final class UsecaseSingleMethod extends DartLintRule {
  /// [UsecaseSingleMethod] の診断コード.
  static const _code = LintCode(
    name: 'usecase_single_method',
    problemMessage:
        '@usecase types must not declare more than one public instance method.',
    errorSeverity: architectureViolationSeverity,
  );

  /// [UsecaseSingleMethod] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = UsecaseSingleMethod();
  /// ```
  const UsecaseSingleMethod() : super(code: _code);

  /// `@usecase` クラスを走査し、public インスタンスメソッドが2つ以上なら報告する.
  ///
  /// [resolver] は解析対象ファイルの解決情報.
  /// [reporter] は診断の出力先.
  /// [context] は解析コンテキスト（AST 登録に使う）.
  ///
  /// Example:
  /// ```dart
  /// rule.run(resolver, reporter, context);
  /// ```
  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      if (!hasUsecaseAnnotation(node)) {
        return;
      }

      final methods = publicInstanceMethodsOf(node).toList(growable: false);
      if (methods.length < 2) {
        return;
      }

      reporter.atToken(node.name, code);
    });
  }
}
