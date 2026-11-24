import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/ast_compat.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_checkers.dart';
import 'package:meta/meta.dart';

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
@internal
final class DelegateExecuteMethod extends AnalysisRule {
  /// [DelegateExecuteMethod] の診断コード.
  static const LintCode code = LintCode(
    'delegate_execute_method',
    '@delegate types must declare exactly one instance method named execute.',
    severity: architectureViolationSeverity,
  );

  /// [DelegateExecuteMethod] ルールを生成する.
  DelegateExecuteMethod()
    : super(
        name: 'delegate_execute_method',
        description:
            '@delegate types must declare exactly one instance method named '
            'execute.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addClassDeclaration(this, _Visitor(this));
  }
}

final class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final DelegateExecuteMethod rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!hasDelegateAnnotation(node)) {
      return;
    }

    final methods = instanceMethodsOf(node).toList(growable: false);
    if (methods.length == 1 && methods.single.name.lexeme == 'execute') {
      return;
    }

    rule.reportAtToken(classDeclarationName(node));
  }
}
