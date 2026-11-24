import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
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
final class ViewModelOnMethodNames extends DartLintRule {
  /// [ViewModelOnMethodNames] の診断コード.
  static const _code = LintCode(
    name: 'viewmodel_on_method_names',
    problemMessage:
        '@viewModel instance/extension methods must be named on... '
        '(close/_close excepted).',
    errorSeverity: architectureViolationSeverity,
  );

  /// [ViewModelOnMethodNames] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = ViewModelOnMethodNames();
  /// ```
  const ViewModelOnMethodNames() : super(code: _code);

  /// `@viewModel` クラスと、その型への extension のメソッド名を検査する.
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

      for (final method in viewModelMethodsWithInvalidNames(node)) {
        reporter.atToken(method.name, code);
      }
    });

    context.registry.addExtensionDeclaration((node) {
      final extendedType = extensionExtendedType(node);
      if (!typeHasViewModelAnnotation(extendedType)) {
        return;
      }

      for (final method in extensionMethodsWithInvalidNames(node)) {
        reporter.atToken(method.name, code);
      }
    });
  }
}
