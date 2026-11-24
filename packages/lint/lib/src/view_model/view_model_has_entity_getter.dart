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

/// `@viewModel` 型が `StateStream<T> get entity` を持つことを検証する Lint.
///
/// Example:
/// ```dart
/// // @internal
/// // @viewModel
/// // final class Bad {
/// //   const Bad({required this.state});
/// //   final MutableStateStream<FooState> state;
/// // }
/// // → viewmodel_has_entity_getter
/// ```
@internal
final class ViewModelHasEntityGetter extends AnalysisRule {
  /// [ViewModelHasEntityGetter] の診断コード.
  static const LintCode code = LintCode(
    'viewmodel_has_entity_getter',
    '@viewModel types must declare a StateStream<T> getter named entity.',
    severity: architectureViolationSeverity,
  );

  /// [ViewModelHasEntityGetter] ルールを生成する.
  ViewModelHasEntityGetter()
    : super(
        name: 'viewmodel_has_entity_getter',
        description:
            '@viewModel types must declare a StateStream<T> getter named '
            'entity.',
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

  final ViewModelHasEntityGetter rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!hasViewModelAnnotation(node)) {
      return;
    }

    if (hasEntityStateStreamGetter(node)) {
      return;
    }

    rule.reportAtToken(classDeclarationName(node));
  }
}
