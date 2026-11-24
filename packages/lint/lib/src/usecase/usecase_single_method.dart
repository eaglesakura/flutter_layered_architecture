import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/ast_compat.dart';
import 'package:flutter_layered_architecture_lint/src/usecase/usecase_checkers.dart';
import 'package:meta/meta.dart';

/// `@usecase` 型の public インスタンスメソッドが2つ以上ないことを検証する Lint.
///
/// public メソッドが2つ以上のとき、型名位置に WARNING を出す.
/// private メソッド（`_` 始まり）は件数に含めない.
///
/// Example:
/// ```dart
/// // @usecase
/// // final class Bad {
/// //   const Bad();
/// //   void a() {}
/// //   void b() {}
/// // }
/// // → usecase_single_method
/// ```
@internal
final class UsecaseSingleMethod extends AnalysisRule {
  /// [UsecaseSingleMethod] の診断コード.
  static const LintCode code = LintCode(
    'usecase_single_method',
    '@usecase types must not declare more than one public instance method.',
    severity: architectureViolationSeverity,
  );

  /// [UsecaseSingleMethod] ルールを生成する.
  UsecaseSingleMethod()
    : super(
        name: 'usecase_single_method',
        description:
            '@usecase types must not declare more than one public instance '
            'method.',
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

  final UsecaseSingleMethod rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!hasUsecaseAnnotation(node)) {
      return;
    }

    final methods = publicInstanceMethodsOf(node).toList(growable: false);
    if (methods.length < 2) {
      return;
    }

    rule.reportAtToken(classDeclarationName(node));
  }
}
