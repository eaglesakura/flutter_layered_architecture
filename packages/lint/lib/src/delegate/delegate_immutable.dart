import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/ast_compat.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_checkers.dart';
import 'package:meta/meta.dart';

/// `@delegate` 型が final フィールドと const コンストラクタを持つことを検証する Lint.
///
/// フィールドはすべて `final` または `const` であること.
/// かつ `const` コンストラクタを1つ以上持つこと.
///
/// Example:
/// ```dart
/// // @internal
/// // @delegate
/// // final class Bad {
/// //   Bad(this.value);
/// //   int value;
/// //   void execute() {}
/// // }
/// // → delegate_immutable
/// ```
@internal
final class DelegateImmutable extends AnalysisRule {
  /// [DelegateImmutable] の診断コード.
  static const LintCode code = LintCode(
    'delegate_immutable',
    '@delegate types must have only final fields and at least one const '
        'constructor.',
    severity: architectureViolationSeverity,
  );

  /// [DelegateImmutable] ルールを生成する.
  DelegateImmutable()
    : super(
        name: 'delegate_immutable',
        description:
            '@delegate types must have only final fields and at least one '
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

  final DelegateImmutable rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!hasDelegateAnnotation(node)) {
      return;
    }

    if (fieldsAreFinalOrConst(node) && hasConstConstructor(node)) {
      return;
    }

    rule.reportAtToken(classDeclarationName(node));
  }
}
