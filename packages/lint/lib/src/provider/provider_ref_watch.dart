import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/provider/provider_checkers.dart';
import 'package:meta/meta.dart';

/// Provider create コールバック直下の `ref.read` を禁止する Lint.
///
/// Example:
/// ```dart
/// // Provider((ref) => Impl(ref.read(Other.provider)), ...) // → provider_ref_watch
/// ```
@internal
final class ProviderRefWatch extends AnalysisRule {
  /// [ProviderRefWatch] の診断コード.
  static const LintCode code = LintCode(
    'provider_ref_watch',
    'Prefer `ref.watch` over `ref.read` inside Provider create callbacks.',
    severity: architectureViolationSeverity,
  );

  /// [ProviderRefWatch] ルールを生成する.
  ProviderRefWatch()
    : super(
        name: 'provider_ref_watch',
        description:
            'Inside Provider create callbacks, use ref.watch instead of '
            'ref.read for dependencies.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _ProviderRefWatchVisitor(this);
    registry.addTopLevelVariableDeclaration(this, visitor);
    registry.addFieldDeclaration(this, visitor);
  }
}

/// [ProviderRefWatch] 用 Visitor.
final class _ProviderRefWatchVisitor extends SimpleAstVisitor<void> {
  /// [rule] へ診断を報告する Visitor を生成する.
  _ProviderRefWatchVisitor(this.rule);

  /// 所属ルール.
  final ProviderRefWatch rule;

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    for (final variable in node.variables.variables) {
      _checkInitializer(variable.initializer);
    }
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    for (final variable in node.fields.variables) {
      _checkInitializer(variable.initializer);
    }
  }

  /// provider-like 初期化子の create 直下 `ref.read` を報告する.
  void _checkInitializer(Expression? initializer) {
    if (!isProviderLikeExpression(initializer)) {
      return;
    }
    final create = createCallbackOfProviderLike(initializer);
    if (create == null) {
      return;
    }
    for (final readCall in directRefInvocations(create, 'read')) {
      rule.reportAtNode(readCall);
    }
  }
}
