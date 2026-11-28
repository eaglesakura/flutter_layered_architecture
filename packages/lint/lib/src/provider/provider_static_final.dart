import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/provider/provider_checkers.dart';
import 'package:meta/meta.dart';

/// Provider-like 宣言を class 系の `static final` に強制する Lint.
///
/// トップレベル、および class 系以外／非 `static final` のフィールドを WARNING する.
/// ローカル変数は対象外.
///
/// Example:
/// ```dart
/// // final top = Provider((ref) => 0); // → provider_static_final
/// // class Ok { static final provider = Provider((ref) => 0); } // OK
/// ```
@internal
final class ProviderStaticFinal extends AnalysisRule {
  /// [ProviderStaticFinal] の診断コード.
  static const LintCode code = LintCode(
    'provider_static_final',
    'Provider-like declarations must be `static final` members of a '
        'class-like type.',
    severity: architectureViolationSeverity,
  );

  /// [ProviderStaticFinal] ルールを生成する.
  ProviderStaticFinal()
    : super(
        name: 'provider_static_final',
        description:
            'Provider-like declarations must be static final members of a '
            'class-like type (not top-level).',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _ProviderStaticFinalVisitor(this);
    registry.addTopLevelVariableDeclaration(this, visitor);
    registry.addFieldDeclaration(this, visitor);
  }
}

/// [ProviderStaticFinal] 用 Visitor.
final class _ProviderStaticFinalVisitor extends SimpleAstVisitor<void> {
  /// [rule] へ診断を報告する Visitor を生成する.
  _ProviderStaticFinalVisitor(this.rule);

  /// 所属ルール.
  final ProviderStaticFinal rule;

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    for (final variable in providerLikeVariablesInTopLevel(node)) {
      rule.reportAtToken(variable.name);
    }
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    for (final variable in providerLikeViolatingFieldVariables(node)) {
      rule.reportAtToken(variable.name);
    }
  }
}
