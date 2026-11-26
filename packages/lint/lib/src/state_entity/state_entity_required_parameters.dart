import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/state_entity/state_entity_checkers.dart';
import 'package:meta/meta.dart';

/// `@state` / `@entity` 型の主データ factory パラメータ制約を検証する Lint.
///
/// Example:
/// ```dart
/// // @Default(0) on a primary factory parameter
/// // → state_entity_required_parameters
/// ```
@internal
final class StateEntityRequiredParameters extends AnalysisRule {
  /// [StateEntityRequiredParameters] の診断コード.
  static const LintCode code = LintCode(
    'state_entity_required_parameters',
    'Primary data factory parameters on @state / @entity types must be required '
        'without @Default or default values.',
    severity: architectureViolationSeverity,
  );

  /// [StateEntityRequiredParameters] ルールを生成する.
  StateEntityRequiredParameters()
    : super(
        name: 'state_entity_required_parameters',
        description:
            'Primary data factory parameters on @state / @entity types must be '
            'required without @Default or default values.',
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

  final StateEntityRequiredParameters rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!appliesStateEntityGateA(node)) {
      return;
    }
    final factory = primaryDataFactoryOf(node);
    if (factory == null) {
      return;
    }
    for (final parameter in factory.parameters.parameters) {
      if (parameterHasDefaultAnnotation(parameter) ||
          parameterHasDartDefaultValue(parameter) ||
          !parameter.isRequired) {
        rule.reportAtNode(parameter);
      }
    }
  }
}
