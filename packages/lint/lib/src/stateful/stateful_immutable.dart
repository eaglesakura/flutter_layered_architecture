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

/// `@stateful` 型が final フィールドと const コンストラクタを持つことを検証する Lint.
///
/// Example:
/// ```dart
/// // @stateful
/// // final class Bad {
/// //   Bad(this.state);
/// //   MutableStateStream<int> state;
/// // }
/// // → stateful_immutable
/// ```
@internal
final class StatefulImmutable extends AnalysisRule {
  /// [StatefulImmutable] の診断コード.
  static const LintCode code = LintCode(
    'stateful_immutable',
    '@stateful types must have only final fields and at least one const '
        'constructor.',
    severity: architectureViolationSeverity,
  );

  /// [StatefulImmutable] ルールを生成する.
  StatefulImmutable()
    : super(
        name: 'stateful_immutable',
        description:
            '@stateful types must have only final fields and at least one '
            'const constructor.',
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

  final StatefulImmutable rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!appliesStatefulRules(node)) {
      return;
    }

    if (fieldsAreFinalOrConst(node) && hasConstConstructor(node)) {
      return;
    }

    rule.reportAtToken(classDeclarationName(node));
  }
}
