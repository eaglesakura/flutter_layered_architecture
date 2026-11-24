import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
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
final class ViewModelEntityFreezed extends DartLintRule {
  /// [ViewModelEntityFreezed] の診断コード.
  static const _code = LintCode(
    name: 'viewmodel_entity_freezed',
    problemMessage:
        'StateStream type argument of entity on @viewModel types must be a '
        'Freezed-annotated class.',
    errorSeverity: architectureViolationSeverity,
  );

  /// [ViewModelEntityFreezed] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = ViewModelEntityFreezed();
  /// ```
  const ViewModelEntityFreezed() : super(code: _code);

  /// `entity` の型引数が Freezed でなければ報告する.
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
      if (isFreezedAnnotatedType(entityType)) {
        return;
      }

      reporter.atToken(getter.name, code);
    });
  }
}
