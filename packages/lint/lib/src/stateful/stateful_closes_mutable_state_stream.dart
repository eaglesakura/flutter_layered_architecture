import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/stateful/stateful_checkers.dart';
import 'package:meta/meta.dart';

/// `@stateful` 型内で `MutableStateStream.close()` が呼ばれることを検証する Lint.
///
/// Example:
/// ```dart
/// // @stateful
/// // final class Bad {
/// //   const Bad({required this.state});
/// //   final MutableStateStream<int> state;
/// // }
/// // → stateful_closes_mutable_state_stream
/// ```
@internal
final class StatefulClosesMutableStateStream extends DartLintRule {
  /// [StatefulClosesMutableStateStream] の診断コード.
  static const _code = LintCode(
    name: 'stateful_closes_mutable_state_stream',
    problemMessage:
        '@stateful types must call MutableStateStream.close() somewhere in '
        'the class.',
    errorSeverity: architectureViolationSeverity,
  );

  /// [StatefulClosesMutableStateStream] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = StatefulClosesMutableStateStream();
  /// ```
  const StatefulClosesMutableStateStream() : super(code: _code);

  /// `@stateful` クラス内に `close()` 呼び出しが無ければ報告する.
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
      if (!appliesStatefulRules(node)) {
        return;
      }

      // MutableStateStream フィールドが無い場合は別ルールで扱う.
      if (!hasMutableStateStreamField(node)) {
        return;
      }

      if (callsMutableStateStreamClose(node)) {
        return;
      }

      reporter.atToken(node.name, code);
    });
  }
}
