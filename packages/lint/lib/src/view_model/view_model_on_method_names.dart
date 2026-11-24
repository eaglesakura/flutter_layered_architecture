import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/view_model/view_model_checkers.dart';
import 'package:meta/meta.dart';

/// `@viewModel` のメソッド名が `on*`（`close` / `_close` 除く）であることを検証する Lint.
///
/// クラス本体のインスタンスメソッドと、当該型への extension method を対象とする.
/// getter / setter は対象外.
/// `close` と `_close` のどちらも命名例外として許容する.
///
/// Example:
/// ```dart
/// // @internal
/// // @viewModel
/// // final class Bad {
/// //   Future<void> doWork() async {}
/// // }
/// // → viewmodel_on_method_names
/// ```
@internal
final class ViewModelOnMethodNames extends AnalysisRule {
  /// [ViewModelOnMethodNames] の診断コード.
  static const LintCode code = LintCode(
    'viewmodel_on_method_names',
    '@viewModel instance/extension methods must be named on... '
        '(close/_close excepted).',
    severity: architectureViolationSeverity,
  );

  /// [ViewModelOnMethodNames] ルールを生成する.
  ViewModelOnMethodNames()
    : super(
        name: 'viewmodel_on_method_names',
        description:
            '@viewModel instance/extension methods must be named on... '
            '(close/_close excepted).',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addClassDeclaration(this, _ClassVisitor(this));
    registry.addExtensionDeclaration(this, _ExtensionVisitor(this));
  }
}

final class _ClassVisitor extends SimpleAstVisitor<void> {
  _ClassVisitor(this.rule);

  final ViewModelOnMethodNames rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!hasViewModelAnnotation(node)) {
      return;
    }

    for (final method in viewModelMethodsWithInvalidNames(node)) {
      rule.reportAtToken(method.name);
    }
  }
}

final class _ExtensionVisitor extends SimpleAstVisitor<void> {
  _ExtensionVisitor(this.rule);

  final ViewModelOnMethodNames rule;

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    final extendedType = extensionExtendedType(node);
    if (!typeHasViewModelAnnotation(extendedType)) {
      return;
    }

    for (final method in extensionMethodsWithInvalidNames(node)) {
      rule.reportAtToken(method.name);
    }
  }
}
