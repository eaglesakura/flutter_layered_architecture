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

/// `@stateful` 型内で `MutableStateStream.close()` が呼ばれることを検証する Lint.
///
/// Example:
/// ```dart
/// // @stateful
/// // final class Bad {
/// //   const Bad({required this.state});
/// //   final MutableStateStream<int> state;
/// // }
/// // → stateful_closes_mutable_state_stream
/// ```
@internal
final class StatefulClosesMutableStateStream extends AnalysisRule {
  /// [StatefulClosesMutableStateStream] の診断コード.
  static const LintCode code = LintCode(
    'stateful_closes_mutable_state_stream',
    '@stateful types must call MutableStateStream.close() somewhere in the '
        'class.',
    severity: architectureViolationSeverity,
  );

  /// [StatefulClosesMutableStateStream] ルールを生成する.
  StatefulClosesMutableStateStream()
    : super(
        name: 'stateful_closes_mutable_state_stream',
        description:
            '@stateful types must call MutableStateStream.close() somewhere '
            'in the class.',
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

  final StatefulClosesMutableStateStream rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!appliesStatefulRules(node)) {
      return;
    }

    // MutableStateStream フィールドが無い場合は別ルールで扱う.
    if (!hasMutableStateStreamField(node)) {
      return;
    }

    if (callsMutableStateStreamClose(node)) {
      return;
    }

    rule.reportAtToken(classDeclarationName(node));
  }
}
