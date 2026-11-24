import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/stateful/stateful_checkers.dart';
import 'package:meta/meta.dart';

/// `@stateful` の `MutableStateStream<T>` について、`T` が Freezed 型であることを検証する Lint.
///
/// Example:
/// ```dart
/// // @stateful
/// // final class Bad {
/// //   const Bad({required this.state});
/// //   final MutableStateStream<List<int>> state;
/// //   Future<void> close() => state.close();
/// // }
/// // → stateful_mutable_state_stream_freezed
/// ```
@internal
final class StatefulMutableStateStreamFreezed extends DartLintRule {
  /// [StatefulMutableStateStreamFreezed] の診断コード.
  static const _code = LintCode(
    name: 'stateful_mutable_state_stream_freezed',
    problemMessage:
        'MutableStateStream type argument on @stateful types must be a '
        'Freezed-annotated class.',
    errorSeverity: architectureViolationSeverity,
  );

  /// [StatefulMutableStateStreamFreezed] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = StatefulMutableStateStreamFreezed();
  /// ```
  const StatefulMutableStateStreamFreezed() : super(code: _code);

  /// `MutableStateStream` フィールドの型引数が Freezed でなければ報告する.
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

      for (final variable in mutableStateStreamFieldsOf(node)) {
        final streamType = variable.declaredFragment?.element.type;
        final stateType = mutableStateStreamStateType(streamType);
        if (isFreezedAnnotatedType(stateType)) {
          continue;
        }
        reporter.atNode(variable, code);
      }
    });
  }
}
