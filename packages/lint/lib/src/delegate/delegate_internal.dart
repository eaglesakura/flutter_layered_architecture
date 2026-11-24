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
@internal
final class DelegateInternal extends AnalysisRule {
  /// [DelegateInternal] の診断コード.
  static const LintCode code = LintCode(
    'delegate_internal',
    '@delegate types must also be annotated with @internal.',
    severity: architectureViolationSeverity,
  );

  /// [DelegateInternal] ルールを生成する.
  DelegateInternal()
    : super(
        name: 'delegate_internal',
        description: '@delegate types must also be annotated with @internal.',
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

  final DelegateInternal rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!hasDelegateAnnotation(node)) {
      return;
    }

    if (hasInternalAnnotation(node)) {
      return;
    }

    rule.reportAtToken(classDeclarationName(node));
  }
}
