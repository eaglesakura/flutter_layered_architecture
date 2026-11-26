import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/ast_compat.dart';
import 'package:flutter_layered_architecture_lint/src/state_entity/state_entity_checkers.dart';
import 'package:meta/meta.dart';

/// 同一型への `@state` と `@entity` の同時付与を禁止する Lint.
///
/// Example:
/// ```dart
/// // @state
/// // @entity
/// // final class Bad {}
/// // → state_entity_exclusive
/// ```
@internal
final class StateEntityExclusive extends AnalysisRule {
  /// [StateEntityExclusive] の診断コード.
  static const LintCode code = LintCode(
    'state_entity_exclusive',
    'Types must not be annotated with both @state and @entity.',
    severity: architectureViolationSeverity,
  );

  /// [StateEntityExclusive] ルールを生成する.
  StateEntityExclusive()
    : super(
        name: 'state_entity_exclusive',
        description:
            'Types must not be annotated with both @state and @entity.',
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

  final StateEntityExclusive rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!appliesStateEntityGateA(node)) {
      return;
    }

    if (!hasStateAndEntityAnnotation(node)) {
      return;
    }

    rule.reportAtToken(classDeclarationName(node));
  }
}
