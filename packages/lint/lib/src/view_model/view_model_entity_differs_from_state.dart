import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/view_model/view_model_checkers.dart';
import 'package:meta/meta.dart';

/// `@viewModel` の entity モデルが state モデルと異なることを検証する Lint.
///
/// Example:
/// ```dart
/// // @internal
/// // @viewModel
/// // final class Bad {
/// //   final MutableStateStream<FooState> state;
/// //   StateStream<FooState> get entity => state;
/// // }
/// // → viewmodel_entity_differs_from_state
/// ```
@internal
final class ViewModelEntityDiffersFromState extends DartLintRule {
  /// [ViewModelEntityDiffersFromState] の診断コード.
  static const _code = LintCode(
    name: 'viewmodel_entity_differs_from_state',
    problemMessage:
        'entity model type on @viewModel must differ from the '
        'MutableStateStream state model type.',
    errorSeverity: architectureViolationSeverity,
  );

  /// [ViewModelEntityDiffersFromState] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = ViewModelEntityDiffersFromState();
  /// ```
  const ViewModelEntityDiffersFromState() : super(code: _code);

  /// entity 型と state 型が同一なら報告する.
  ///
  /// [resolver] は解析対象ファイルの解決情報.
  /// [reporter] は診断の出力先.
  /// [context] は解析コンテキスト（AST 登録に使う）.
  ///
  /// Example:
  /// ```dart
  /// rule.run(resolver, reporter, context);
  /// ```
  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      if (!hasViewModelAnnotation(node)) {
        return;
      }

      final getter = entityGetterOf(node);
      if (getter == null) {
        return;
      }

      final entityType = entityModelTypeOf(node);
      final stateType = primaryStateModelTypeOf(node);
      if (entityType == null || stateType == null) {
        return;
      }
      if (!interfaceTypesAreSame(entityType, stateType)) {
        return;
      }

      reporter.atToken(getter.name, code);
    });
  }
}
