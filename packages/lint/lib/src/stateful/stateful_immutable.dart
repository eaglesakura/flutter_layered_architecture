import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/stateful/stateful_checkers.dart';

/// `@stateful` 型が final フィールドと const コンストラクタを持つことを検証する Lint.
///
/// Example:
/// ```dart
/// // @stateful
/// // final class Bad {
/// //   Bad(this.state);
/// //   MutableStateStream<int> state;
/// // }
/// // → stateful_immutable
/// ```
final class StatefulImmutable extends DartLintRule {
  /// [StatefulImmutable] の診断コード.
  static const _code = LintCode(
    name: 'stateful_immutable',
    problemMessage:
        '@stateful types must have only final fields and at least one const '
        'constructor.',
    errorSeverity: architectureViolationSeverity,
  );

  /// [StatefulImmutable] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = StatefulImmutable();
  /// ```
  const StatefulImmutable() : super(code: _code);

  /// `@stateful` クラスのフィールドとコンストラクタを検査し、違反なら報告する.
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
      if (!hasStatefulAnnotation(node)) {
        return;
      }

      if (fieldsAreFinalOrConst(node) && hasConstConstructor(node)) {
        return;
      }

      reporter.atToken(node.name, code);
    });
  }
}
