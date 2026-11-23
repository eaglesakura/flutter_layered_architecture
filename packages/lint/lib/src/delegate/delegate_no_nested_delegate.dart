import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_type_checkers.dart';

/// `@delegate` 内での別 `@delegate` の受け取り・生成を禁止する Lint.
///
/// コンストラクタ引数の型が `@delegate` 付きであってはならない.
/// またクラス内で `@delegate` 付き型を `new` / コンストラクタ呼び出ししてはならない.
///
/// Example:
/// ```dart
/// // @internal
/// // @delegate
/// // final class Bad {
/// //   const Bad(this.other);
/// //   final OtherDelegate other; // NG
/// //   void execute() {}
/// // }
/// // → delegate_no_nested_delegate
/// ```
final class DelegateNoNestedDelegate extends DartLintRule {
  /// [DelegateNoNestedDelegate] の診断コード.
  static const _code = LintCode(
    name: 'delegate_no_nested_delegate',
    problemMessage:
        '@delegate types must not accept or instantiate other @delegate '
        'types.',
    errorSeverity: architectureViolationSeverity,
  );

  /// [DelegateNoNestedDelegate] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = DelegateNoNestedDelegate();
  /// ```
  const DelegateNoNestedDelegate() : super(code: _code);

  /// コンストラクタ引数とインスタンス生成を検査し、入れ子 Delegate なら報告する.
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

      for (final constructor
          in node.members.whereType<ConstructorDeclaration>()) {
        for (final parameter in constructor.parameters.parameters) {
          final type = resolvedTypeOfParameter(parameter);
          if (!typeHasAnnotation(type, delegateAnnotationChecker)) {
            continue;
          }
          reporter.atNode(parameter, code);
        }
      }
    });

    context.registry.addInstanceCreationExpression((node) {
      final enclosing = enclosingClassOf(node);
      if (enclosing == null || !hasDelegateAnnotation(enclosing)) {
        return;
      }
      if (!typeHasAnnotation(node.staticType, delegateAnnotationChecker)) {
        return;
      }
      reporter.atNode(node, code);
    });
  }
}
