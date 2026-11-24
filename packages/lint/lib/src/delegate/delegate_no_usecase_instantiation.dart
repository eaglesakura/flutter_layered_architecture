import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_type_checkers.dart';
import 'package:meta/meta.dart';

/// `@delegate` 内での `@usecase` 型の生成を禁止する Lint.
///
/// `@usecase` 付き型はコンストラクタ引数として受け取り、内部で `new` しない.
///
/// Example:
/// ```dart
/// // @internal
/// // @delegate
/// // final class Bad {
/// //   const Bad();
/// //   void execute() {
/// //     final usecase = SomeUsecase(); // NG
/// //   }
/// // }
/// // → delegate_no_usecase_instantiation
/// ```
@internal
final class DelegateNoUsecaseInstantiation extends AnalysisRule {
  /// [DelegateNoUsecaseInstantiation] の診断コード.
  static const LintCode code = LintCode(
    'delegate_no_usecase_instantiation',
    '@delegate types must not instantiate @usecase types; inject them via the '
        'constructor instead.',
    severity: architectureViolationSeverity,
  );

  /// [DelegateNoUsecaseInstantiation] ルールを生成する.
  DelegateNoUsecaseInstantiation()
    : super(
        name: 'delegate_no_usecase_instantiation',
        description:
            '@delegate types must not instantiate @usecase types; inject '
            'them via the constructor instead.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addInstanceCreationExpression(this, _Visitor(this));
  }
}

final class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final DelegateNoUsecaseInstantiation rule;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final enclosing = enclosingClassOf(node);
    if (enclosing == null || !hasDelegateAnnotation(enclosing)) {
      return;
    }
    if (!typeHasAnnotation(node.staticType, usecaseAnnotationChecker)) {
      return;
    }
    rule.reportAtNode(node);
  }
}
