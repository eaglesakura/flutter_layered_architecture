import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/view_model/view_model_checkers.dart';

/// `@viewModel` 型に `@internal` が付いていることを検証する Lint.
///
/// Example:
/// ```dart
/// // @viewModel
/// // final class Bad {
/// //   const Bad({required this.state});
/// //   final MutableStateStream<FooState> state;
/// // }
/// // → viewmodel_internal
/// ```
final class ViewModelInternal extends DartLintRule {
  /// [ViewModelInternal] の診断コード.
  static const _code = LintCode(
    name: 'viewmodel_internal',
    problemMessage: '@viewModel types must also be annotated with @internal.',
    errorSeverity: architectureViolationSeverity,
  );

  /// [ViewModelInternal] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = ViewModelInternal();
  /// ```
  const ViewModelInternal() : super(code: _code);

  /// `@viewModel` クラスに `@internal` が無ければ報告する.
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

      if (hasInternalAnnotation(node)) {
        return;
      }

      reporter.atToken(node.name, code);
    });
  }
}
