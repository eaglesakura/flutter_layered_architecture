import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/ast_compat.dart';
import 'package:flutter_layered_architecture_lint/src/stateful/stateful_checkers.dart';
import 'package:meta/meta.dart';

/// `@stateful` 型が `MutableStateStream` フィールドを持つことを検証する Lint.
///
/// Example:
/// ```dart
/// // @stateful
/// // final class Bad {
/// //   const Bad();
/// // }
/// // → stateful_has_mutable_state_stream
/// ```
@internal
final class StatefulHasMutableStateStream extends AnalysisRule {
  /// [StatefulHasMutableStateStream] の診断コード.
  static const LintCode code = LintCode(
    'stateful_has_mutable_state_stream',
    '@stateful types must declare at least one MutableStateStream field.',
    severity: architectureViolationSeverity,
  );

  /// [StatefulHasMutableStateStream] ルールを生成する.
  StatefulHasMutableStateStream()
    : super(
        name: 'stateful_has_mutable_state_stream',
        description:
            '@stateful types must declare at least one MutableStateStream '
            'field.',
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

  final StatefulHasMutableStateStream rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!appliesStatefulRules(node)) {
      return;
    }

    if (hasMutableStateStreamField(node)) {
      return;
    }

    rule.reportAtToken(classDeclarationName(node));
  }
}
