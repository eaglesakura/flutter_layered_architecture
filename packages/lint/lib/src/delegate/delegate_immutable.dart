import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_checkers.dart';
import 'package:meta/meta.dart';

/// `@delegate` 型が final フィールドと const コンストラクタを持つことを検証する Lint.
///
/// フィールドはすべて `final` または `const` であること.
/// かつ `const` コンストラクタを1つ以上持つこと.
///
/// Example:
/// ```dart
/// // @internal
/// // @delegate
/// // final class Bad {
/// //   Bad(this.value);
/// //   int value;
/// //   void execute() {}
/// // }
/// // → delegate_immutable
/// ```
@internal
final class DelegateImmutable extends DartLintRule {
  /// [DelegateImmutable] の診断コード.
  static const _code = LintCode(
    name: 'delegate_immutable',
    problemMessage:
        '@delegate types must have only final fields and at least one const '
        'constructor.',
    errorSeverity: architectureViolationSeverity,
  );

  /// [DelegateImmutable] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = DelegateImmutable();
  /// ```
  const DelegateImmutable() : super(code: _code);

  /// `@delegate` クラスのフィールドとコンストラクタを検査し、違反なら報告する.
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
      if (!hasDelegateAnnotation(node)) {
        return;
      }

      if (fieldsAreFinalOrConst(node) && hasConstConstructor(node)) {
        return;
      }

      reporter.atToken(node.name, code);
    });
  }
}
