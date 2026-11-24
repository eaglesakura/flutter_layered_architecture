import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/ast_compat.dart';
import 'package:flutter_layered_architecture_lint/src/view_model/view_model_checkers.dart';
import 'package:meta/meta.dart';

/// `@viewModel` 型に `@internal` が付いていることを検証する Lint.
///
/// Example:
/// ```dart
/// // @viewModel
/// // final class Bad {
/// //   const Bad({required this.state});
/// //   final MutableStateStream<FooState> state;
/// // }
/// // → viewmodel_internal
/// ```
@internal
final class ViewModelInternal extends AnalysisRule {
  /// [ViewModelInternal] の診断コード.
  static const LintCode code = LintCode(
    'viewmodel_internal',
    '@viewModel types must also be annotated with @internal.',
    severity: architectureViolationSeverity,
  );

  /// [ViewModelInternal] ルールを生成する.
  ViewModelInternal()
    : super(
        name: 'viewmodel_internal',
        description: '@viewModel types must also be annotated with @internal.',
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

  final ViewModelInternal rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!hasViewModelAnnotation(node)) {
      return;
    }

    if (hasInternalAnnotation(node)) {
      return;
    }

    rule.reportAtToken(classDeclarationName(node));
  }
}
