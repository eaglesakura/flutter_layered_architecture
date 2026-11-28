import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/provider/provider_checkers.dart';
import 'package:meta/meta.dart';

/// create 直下の `ref.watch` 参照を `dependencies` に列挙させる Lint.
///
/// `ref.watch` が無い宣言は対象外。余分な dependencies エントリは許容する.
///
/// Example:
/// ```dart
/// // Provider((ref) => Impl(ref.watch(Other.provider))) // dependencies 欠落 → WARNING
/// ```
@internal
final class ProviderDependencies extends AnalysisRule {
  /// [ProviderDependencies] の診断コード.
  static const LintCode code = LintCode(
    'provider_dependencies',
    'Providers passed to `ref.watch` must be listed in `dependencies`.',
    severity: architectureViolationSeverity,
  );

  /// [ProviderDependencies] ルールを生成する.
  ProviderDependencies()
    : super(
        name: 'provider_dependencies',
        description:
            'Each ref.watch argument in a Provider create callback must appear '
            'in the dependencies list (literal match).',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _ProviderDependenciesVisitor(this);
    registry.addTopLevelVariableDeclaration(this, visitor);
    registry.addFieldDeclaration(this, visitor);
  }
}

/// [ProviderDependencies] 用 Visitor.
final class _ProviderDependenciesVisitor extends SimpleAstVisitor<void> {
  /// [rule] へ診断を報告する Visitor を生成する.
  _ProviderDependenciesVisitor(this.rule);

  /// 所属ルール.
  final ProviderDependencies rule;

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

  /// provider-like 初期化子の未列挙 `ref.watch` を報告する.
  void _checkInitializer(Expression? initializer) {
    if (!isProviderLikeExpression(initializer)) {
      return;
    }
    final create = createCallbackOfProviderLike(initializer);
    if (create == null) {
      return;
    }
    final watches = directRefInvocations(
      create,
      'watch',
    ).toList(growable: false);
    if (watches.isEmpty) {
      return;
    }
    final deps = dependenciesLiteralsOf(initializer);
    for (final watch in watches) {
      if (!isWatchListedInDependencies(watch, deps)) {
        rule.reportAtNode(watch);
      }
    }
  }
}
