import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_type_checkers.dart';

/// `@delegate` 内での `@usecase` 型の生成を禁止する Lint.
///
/// `@usecase` 付き型はコンストラクタ引数として受け取り、内部で `new` しない.
///
/// Example:
/// ```dart
/// // @internal
/// // @delegate
/// // final class Bad {
/// //   const Bad();
/// //   void execute() {
/// //     final usecase = SomeUsecase(); // NG
/// //   }
/// // }
/// // → delegate_no_usecase_instantiation
/// ```
final class DelegateNoUsecaseInstantiation extends DartLintRule {
  /// [DelegateNoUsecaseInstantiation] の診断コード.
  static const _code = LintCode(
    name: 'delegate_no_usecase_instantiation',
    problemMessage:
        '@delegate types must not instantiate @usecase types; inject them via '
        'the constructor instead.',
    errorSeverity: architectureViolationSeverity,
  );

  /// [DelegateNoUsecaseInstantiation] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = DelegateNoUsecaseInstantiation();
  /// ```
  const DelegateNoUsecaseInstantiation() : super(code: _code);

  /// `@delegate` 内のインスタンス生成を検査し、`@usecase` 生成なら報告する.
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
    context.registry.addInstanceCreationExpression((node) {
      final enclosing = enclosingClassOf(node);
      if (enclosing == null || !hasDelegateAnnotation(enclosing)) {
        return;
      }
      if (!typeHasAnnotation(node.staticType, usecaseAnnotationChecker)) {
        return;
      }
      reporter.atNode(node, code);
    });
  }
}
