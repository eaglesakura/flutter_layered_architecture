import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/stateful/stateful_checkers.dart';

/// `@stateful` 型が `MutableStateStream` フィールドを持つことを検証する Lint.
///
/// Example:
/// ```dart
/// // @stateful
/// // final class Bad {
/// //   const Bad();
/// // }
/// // → stateful_has_mutable_state_stream
/// ```
final class StatefulHasMutableStateStream extends DartLintRule {
  /// [StatefulHasMutableStateStream] の診断コード.
  static const _code = LintCode(
    name: 'stateful_has_mutable_state_stream',
    problemMessage:
        '@stateful types must declare at least one MutableStateStream field.',
  );

  /// [StatefulHasMutableStateStream] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = StatefulHasMutableStateStream();
  /// ```
  const StatefulHasMutableStateStream() : super(code: _code);

  /// `@stateful` クラスに `MutableStateStream` フィールドが無ければ報告する.
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

      if (hasMutableStateStreamField(node)) {
        return;
      }

      reporter.atToken(node.name, code);
    });
  }
}
