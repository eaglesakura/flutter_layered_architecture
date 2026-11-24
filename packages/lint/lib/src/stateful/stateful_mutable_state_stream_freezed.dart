import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/stateful/stateful_checkers.dart';
import 'package:meta/meta.dart';

/// `@stateful` の `MutableStateStream<T>` について、`T` が Freezed 型であることを検証する Lint.
///
/// Example:
/// ```dart
/// // @stateful
/// // final class Bad {
/// //   const Bad({required this.state});
/// //   final MutableStateStream<List<int>> state;
/// //   Future<void> close() => state.close();
/// // }
/// // → stateful_mutable_state_stream_freezed
/// ```
@internal
final class StatefulMutableStateStreamFreezed extends AnalysisRule {
  /// [StatefulMutableStateStreamFreezed] の診断コード.
  static const LintCode code = LintCode(
    'stateful_mutable_state_stream_freezed',
    'MutableStateStream type argument on @stateful types must be a '
        'Freezed-annotated class.',
    severity: architectureViolationSeverity,
  );

  /// [StatefulMutableStateStreamFreezed] ルールを生成する.
  StatefulMutableStateStreamFreezed()
    : super(
        name: 'stateful_mutable_state_stream_freezed',
        description:
            'MutableStateStream type argument on @stateful types must be a '
            'Freezed-annotated class.',
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

  final StatefulMutableStateStreamFreezed rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!appliesStatefulRules(node)) {
      return;
    }

    for (final variable in mutableStateStreamFieldsOf(node)) {
      final streamType = variable.declaredFragment?.element.type;
      final stateType = mutableStateStreamStateType(streamType);
      if (isFreezedAnnotatedType(stateType)) {
        continue;
      }
      rule.reportAtNode(variable);
    }
  }
}
