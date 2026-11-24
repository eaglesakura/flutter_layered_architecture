import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/view_model/view_model_checkers.dart';
import 'package:meta/meta.dart';

/// `@viewModel` の entity モデルが state モデルと異なることを検証する Lint.
///
/// Example:
/// ```dart
/// // @internal
/// // @viewModel
/// // final class Bad {
/// //   final MutableStateStream<FooState> state;
/// //   StateStream<FooState> get entity => state;
/// // }
/// // → viewmodel_entity_differs_from_state
/// ```
@internal
final class ViewModelEntityDiffersFromState extends AnalysisRule {
  /// [ViewModelEntityDiffersFromState] の診断コード.
  static const LintCode code = LintCode(
    'viewmodel_entity_differs_from_state',
    'entity model type on @viewModel must differ from the '
        'MutableStateStream state model type.',
    severity: architectureViolationSeverity,
  );

  /// [ViewModelEntityDiffersFromState] ルールを生成する.
  ViewModelEntityDiffersFromState()
    : super(
        name: 'viewmodel_entity_differs_from_state',
        description:
            'entity model type on @viewModel must differ from the '
            'MutableStateStream state model type.',
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

  final ViewModelEntityDiffersFromState rule;

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
    final stateType = primaryStateModelTypeOf(node);
    if (entityType == null || stateType == null) {
      return;
    }
    if (!interfaceTypesAreSame(entityType, stateType)) {
      return;
    }

    rule.reportAtToken(getter.name);
  }
}
