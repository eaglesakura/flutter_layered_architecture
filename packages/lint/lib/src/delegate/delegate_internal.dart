import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_checkers.dart';

/// `@delegate` 型に `@internal` が付いていることを検証する Lint.
///
/// Example:
/// ```dart
/// // @delegate
/// // final class Bad {
/// //   const Bad();
/// //   void execute() {}
/// // }
/// // → delegate_internal
/// ```
final class DelegateInternal extends DartLintRule {
  /// [DelegateInternal] の診断コード.
  static const _code = LintCode(
    name: 'delegate_internal',
    problemMessage: '@delegate types must also be annotated with @internal.',
    errorSeverity: architectureViolationSeverity,
  );

  /// [DelegateInternal] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = DelegateInternal();
  /// ```
  const DelegateInternal() : super(code: _code);

  /// `@delegate` クラスに `@internal` が無ければ報告する.
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
      if (!hasDelegateAnnotation(node)) {
        return;
      }

      if (hasInternalAnnotation(node)) {
        return;
      }

      reporter.atToken(node.name, code);
    });
  }
}
