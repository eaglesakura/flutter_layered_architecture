import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/view_model/view_model_checkers.dart';
import 'package:meta/meta.dart';

/// `@viewModel` の `entity` 型引数が Freezed 型であることを検証する Lint.
///
/// Example:
/// ```dart
/// // @internal
/// // @viewModel
/// // final class Bad {
/// //   StateStream<List<int>> get entity => ...;
/// // }
/// // → viewmodel_entity_freezed
/// ```
@internal
final class ViewModelEntityFreezed extends AnalysisRule {
  /// [ViewModelEntityFreezed] の診断コード.
  static const LintCode code = LintCode(
    'viewmodel_entity_freezed',
    'StateStream type argument of entity on @viewModel types must be a '
        'Freezed-annotated class.',
    severity: architectureViolationSeverity,
  );

  /// [ViewModelEntityFreezed] ルールを生成する.
  ViewModelEntityFreezed()
    : super(
        name: 'viewmodel_entity_freezed',
        description:
            'StateStream type argument of entity on @viewModel types must be '
            'a Freezed-annotated class.',
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

  final ViewModelEntityFreezed rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!hasViewModelAnnotation(node)) {
      return;
    }

    final getter = entityGetterOf(node);
    if (getter == null) {
      return;
    }

    final entityType = entityModelTypeOf(node);
    if (isFreezedAnnotatedType(entityType)) {
      return;
    }

    rule.reportAtToken(getter.name);
  }
}
