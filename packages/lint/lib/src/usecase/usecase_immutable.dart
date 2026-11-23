import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/usecase/usecase_checkers.dart';

/// `@usecase` 型が final フィールドと const コンストラクタを持つことを検証する Lint.
///
/// フィールドはすべて `final` または `const` であること.
/// かつ `const` コンストラクタを1つ以上持つこと.
///
/// Example:
/// ```dart
/// // @usecase
/// // final class Bad {
/// //   Bad(this.value);
/// //   int value;
/// //   int execute(int request) => request;
/// // }
/// // → usecase_immutable
/// ```
final class UsecaseImmutable extends DartLintRule {
  /// [UsecaseImmutable] の診断コード.
  static const _code = LintCode(
    name: 'usecase_immutable',
    problemMessage:
        '@usecase types must have only final fields and at least one const '
        'constructor.',
  );

  /// [UsecaseImmutable] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = UsecaseImmutable();
  /// ```
  const UsecaseImmutable() : super(code: _code);

  /// `@usecase` クラスのフィールドとコンストラクタを検査し、違反なら報告する.
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
      if (!hasUsecaseAnnotation(node)) {
        return;
      }

      final fieldsAreFinal = node.members.whereType<FieldDeclaration>().every(
        (field) => field.fields.isFinal || field.fields.isConst,
      );
      final hasConstConstructor = node.members
          .whereType<ConstructorDeclaration>()
          .any((constructor) => constructor.constKeyword != null);

      if (fieldsAreFinal && hasConstConstructor) {
        return;
      }

      reporter.atToken(node.name, code);
    });
  }
}
