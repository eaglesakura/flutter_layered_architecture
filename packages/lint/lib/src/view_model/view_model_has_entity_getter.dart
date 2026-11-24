import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/view_model/view_model_checkers.dart';
import 'package:meta/meta.dart';

/// `@viewModel` 型が `StateStream<T> get entity` を持つことを検証する Lint.
///
/// Example:
/// ```dart
/// // @internal
/// // @viewModel
/// // final class Bad {
/// //   const Bad({required this.state});
/// //   final MutableStateStream<FooState> state;
/// // }
/// // → viewmodel_has_entity_getter
/// ```
@internal
final class ViewModelHasEntityGetter extends DartLintRule {
  /// [ViewModelHasEntityGetter] の診断コード.
  static const _code = LintCode(
    name: 'viewmodel_has_entity_getter',
    problemMessage:
        '@viewModel types must declare a StateStream<T> getter named entity.',
    errorSeverity: architectureViolationSeverity,
  );

  /// [ViewModelHasEntityGetter] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = ViewModelHasEntityGetter();
  /// ```
  const ViewModelHasEntityGetter() : super(code: _code);

  /// `@viewModel` クラスに `entity` getter が無ければ報告する.
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

      if (hasEntityStateStreamGetter(node)) {
        return;
      }

      reporter.atToken(node.name, code);
    });
  }
}
