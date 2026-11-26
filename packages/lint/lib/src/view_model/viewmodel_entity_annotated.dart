import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/state_entity/state_entity_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/view_model/view_model_checkers.dart';
import 'package:meta/meta.dart';

/// `@viewModel` の `entity` 型引数に `@entity` があることを検証する Lint.
///
/// Example:
/// ```dart
/// // @internal
/// // @viewModel
/// // final class Bad {
/// //   StateStream<List<int>> get entity => throw UnimplementedError();
/// // }
/// // → viewmodel_entity_annotated
/// ```
@internal
final class ViewModelEntityAnnotated extends AnalysisRule {
  /// [ViewModelEntityAnnotated] の診断コード.
  static const LintCode code = LintCode(
    'viewmodel_entity_annotated',
    'StateStream type argument of entity on @viewModel types must be a '
        'class annotated with @entity.',
    severity: architectureViolationSeverity,
  );

  /// [ViewModelEntityAnnotated] ルールを生成する.
  ViewModelEntityAnnotated()
    : super(
        name: 'viewmodel_entity_annotated',
        description:
            'StateStream type argument of entity on @viewModel types must be '
            'a class annotated with @entity.',
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

  final ViewModelEntityAnnotated rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!hasViewModelAnnotation(node)) {
      return;
    }

    final getter = entityGetterOf(node);
    if (getter == null) {
      return;
    }

    final entityType = entityModelTypeOf(node);
    if (typeHasEntityAnnotation(entityType)) {
      return;
    }

    rule.reportAtToken(getter.name);
  }
}
