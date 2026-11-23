import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_checkers.dart';

/// `@delegate` 型が `execute` インスタンスメソッドだけを持つことを検証する Lint.
///
/// インスタンスメソッドはちょうど1つで、名前が `execute` であること.
/// 戻り値型・引数の有無は任意とする.
///
/// Example:
/// ```dart
/// // @internal
/// // @delegate
/// // final class Bad {
/// //   const Bad();
/// //   void run() {}
/// // }
/// // → delegate_execute_method
/// ```
final class DelegateExecuteMethod extends DartLintRule {
  /// [DelegateExecuteMethod] の診断コード.
  static const _code = LintCode(
    name: 'delegate_execute_method',
    problemMessage:
        '@delegate types must declare exactly one instance method named '
        'execute.',
    errorSeverity: architectureViolationSeverity,
  );

  /// [DelegateExecuteMethod] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = DelegateExecuteMethod();
  /// ```
  const DelegateExecuteMethod() : super(code: _code);

  /// `@delegate` クラスを走査し、`execute` 以外または複数メソッドなら報告する.
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

      final methods = instanceMethodsOf(node).toList(growable: false);
      if (methods.length == 1 && methods.single.name.lexeme == 'execute') {
        return;
      }

      reporter.atToken(node.name, code);
    });
  }
}
