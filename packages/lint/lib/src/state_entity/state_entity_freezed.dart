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

/// `@state` / `@entity` 型に Freezed が付いていることを検証する Lint.
///
/// Example:
/// ```dart
/// // @state
/// // final class Bad {}
/// // → state_entity_freezed
/// ```
@internal
final class StateEntityFreezed extends AnalysisRule {
  /// [StateEntityFreezed] の診断コード.
  static const LintCode code = LintCode(
    'state_entity_freezed',
    '@state / @entity types must also be annotated with @freezed or @Freezed.',
    severity: architectureViolationSeverity,
  );

  /// [StateEntityFreezed] ルールを生成する.
  StateEntityFreezed()
    : super(
        name: 'state_entity_freezed',
        description: '@state / @entity types must also be annotated with @freezed or @Freezed.',
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

  final StateEntityFreezed rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!appliesStateEntityGateA(node)) {
      return;
    }

    if (classHasFreezedAnnotation(node)) {
      return;
    }

    rule.reportAtToken(classDeclarationName(node));
  }
}
