import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/state_entity/state_entity_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/stateful/stateful_checkers.dart';
import 'package:meta/meta.dart';

/// `@stateful` の `MutableStateStream<T>` について、型引数 `T` に `@state` があることを検証する Lint.
///
/// Example:
/// ```dart
/// // @stateful
/// // final class Bad {
/// //   const Bad({required this.state});
/// //   final MutableStateStream<List<int>> state;
/// //   Future<void> close() => state.close();
/// // }
/// // → stateful_mutable_state_stream_state
/// ```
@internal
final class StatefulMutableStateStreamState extends AnalysisRule {
  /// [StatefulMutableStateStreamState] の診断コード.
  static const LintCode code = LintCode(
    'stateful_mutable_state_stream_state',
    'MutableStateStream type argument on @stateful types must be a '
        'class annotated with @state.',
    severity: architectureViolationSeverity,
  );

  /// [StatefulMutableStateStreamState] ルールを生成する.
  StatefulMutableStateStreamState()
    : super(
        name: 'stateful_mutable_state_stream_state',
        description:
            'MutableStateStream type argument on @stateful types must be a '
            'class annotated with @state.',
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

  final StatefulMutableStateStreamState rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!appliesStatefulRules(node)) {
      return;
    }

    for (final variable in mutableStateStreamFieldsOf(node)) {
      final streamType = variable.declaredFragment?.element.type;
      final stateType = mutableStateStreamStateType(streamType);
      if (typeHasStateAnnotation(stateType)) {
        continue;
      }
      rule.reportAtNode(variable);
    }
  }
}
