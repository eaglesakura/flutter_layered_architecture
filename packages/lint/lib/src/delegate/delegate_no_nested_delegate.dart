import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/ast_compat.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_type_checkers.dart';
import 'package:meta/meta.dart';

/// `@delegate` 内での別 `@delegate` の受け取り・生成を禁止する Lint.
///
/// コンストラクタ引数の型が `@delegate` 付きであってはならない.
/// またクラス内で `@delegate` 付き型を `new` / コンストラクタ呼び出ししてはならない.
///
/// Example:
/// ```dart
/// // @internal
/// // @delegate
/// // final class Bad {
/// //   const Bad(this.other);
/// //   final OtherDelegate other; // NG
/// //   void execute() {}
/// // }
/// // → delegate_no_nested_delegate
/// ```
@internal
final class DelegateNoNestedDelegate extends AnalysisRule {
  /// [DelegateNoNestedDelegate] の診断コード.
  static const LintCode code = LintCode(
    'delegate_no_nested_delegate',
    '@delegate types must not accept or instantiate other @delegate types.',
    severity: architectureViolationSeverity,
  );

  /// [DelegateNoNestedDelegate] ルールを生成する.
  DelegateNoNestedDelegate()
    : super(
        name: 'delegate_no_nested_delegate',
        description:
            '@delegate types must not accept or instantiate other @delegate '
            'types.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addClassDeclaration(this, _ClassVisitor(this));
    registry.addInstanceCreationExpression(this, _CreationVisitor(this));
  }
}

final class _ClassVisitor extends SimpleAstVisitor<void> {
  _ClassVisitor(this.rule);

  final DelegateNoNestedDelegate rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!hasDelegateAnnotation(node)) {
      return;
    }

    for (final constructor
        in classDeclarationMembers(node).whereType<ConstructorDeclaration>()) {
      for (final parameter in constructor.parameters.parameters) {
        final type = resolvedTypeOfParameter(parameter);
        if (!typeHasAnnotation(type, delegateAnnotationChecker)) {
          continue;
        }
        rule.reportAtNode(parameter);
      }
    }
  }
}

final class _CreationVisitor extends SimpleAstVisitor<void> {
  _CreationVisitor(this.rule);

  final DelegateNoNestedDelegate rule;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final enclosing = enclosingClassOf(node);
    if (enclosing == null || !hasDelegateAnnotation(enclosing)) {
      return;
    }
    if (!typeHasAnnotation(node.staticType, delegateAnnotationChecker)) {
      return;
    }
    rule.reportAtNode(node);
  }
}
