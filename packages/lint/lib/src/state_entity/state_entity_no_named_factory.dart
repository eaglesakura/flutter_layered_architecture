import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/state_entity/state_entity_checkers.dart';
import 'package:meta/meta.dart';

/// `@state` / `@entity` 型の named factory 定義を検出する Lint.
///
/// Example:
/// ```dart
/// // factory MyState.initial() => ...
/// // → state_entity_no_named_factory
/// ```
@internal
final class StateEntityNoNamedFactory extends AnalysisRule {
  /// [StateEntityNoNamedFactory] の診断コード.
  static const LintCode code = LintCode(
    'state_entity_no_named_factory',
    'Named factories on @state / @entity types are discouraged; require all '
        'arguments at call sites.',
    severity: architectureViolationSeverity,
  );

  /// [StateEntityNoNamedFactory] ルールを生成する.
  StateEntityNoNamedFactory()
    : super(
        name: 'state_entity_no_named_factory',
        description:
            'Named factories on @state / @entity types are discouraged; '
            'require all arguments at call sites.',
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

  final StateEntityNoNamedFactory rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!appliesStateEntityGateA(node)) {
      return;
    }
    for (final constructor in namedFactoriesOf(node)) {
      final name = constructor.name;
      if (name != null) {
        rule.reportAtToken(name);
      }
    }
  }
}
