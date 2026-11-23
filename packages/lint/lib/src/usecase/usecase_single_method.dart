import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/usecase/usecase_checkers.dart';

/// `@usecase` 型がインスタンスメソッドをちょうど1つ持つことを検証する Lint.
///
/// メソッド数が 0 または 2 以上のとき、型名位置に診断を出す.
///
/// Example:
/// ```dart
/// // analysis_options.yaml で custom_lint を有効化したうえで:
/// // @usecase
/// // final class Bad {
/// //   const Bad();
/// //   void a() {}
/// //   void b() {}
/// // }
/// // → usecase_single_method
/// ```
final class UsecaseSingleMethod extends DartLintRule {
  /// [UsecaseSingleMethod] の診断コード.
  static const _code = LintCode(
    name: 'usecase_single_method',
    problemMessage: '@usecase types must declare exactly one instance method.',
  );

  /// [UsecaseSingleMethod] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = UsecaseSingleMethod();
  /// ```
  const UsecaseSingleMethod() : super(code: _code);

  /// `@usecase` クラスを走査し、インスタンスメソッド数が1以外なら報告する.
  ///
  /// [resolver] は解析対象ファイルの解決情報.
  /// [reporter] は診断の出力先.
  /// [context] は解析コンテキスト（AST 登録に使う）.
  ///
  /// Example:
  /// ```dart
  /// // custom_lint が各 Dart ファイル解析時に呼び出す.
  /// rule.run(resolver, reporter, context);
  /// ```
  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      if (!hasUsecaseAnnotation(node)) {
        return;
      }

      final methods = instanceMethodsOf(node).toList(growable: false);
      if (methods.length == 1) {
        return;
      }

      reporter.atToken(node.name, code);
    });
  }
}
