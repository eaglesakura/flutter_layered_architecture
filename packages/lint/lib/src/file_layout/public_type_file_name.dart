import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/file_layout/file_layout_checkers.dart';
import 'package:meta/meta.dart';

/// 唯一の public 型名とファイル名（lower_snake_case）の一致を検証する Lint.
///
/// public 型が0または2つ以上のときは報告しない（件数ルール側で扱う）.
/// `part of` と `test/` 配下は対象外.
///
/// Example:
/// ```dart
/// // file: wrong_name.dart
/// // final class AddTodoRequest {}
/// // → public_type_file_name
/// ```
@internal
final class PublicTypeFileName extends DartLintRule {
  /// [PublicTypeFileName] の診断コード.
  static const _code = LintCode(
    name: 'public_type_file_name',
    problemMessage:
        'The file name must be the lower_snake_case form of the single '
        'public type name.',
    errorSeverity: architectureViolationSeverity,
  );

  /// [PublicTypeFileName] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = PublicTypeFileName();
  /// ```
  const PublicTypeFileName() : super(code: _code);

  /// 唯一の public 型があるとき、ファイル名が期待と一致しなければ報告する.
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
    context.registry.addCompilationUnit((unit) {
      if (shouldSkipFileLayoutLint(path: resolver.path, unit: unit)) {
        return;
      }

      final types = publicNamedTypesOf(unit).toList(growable: false);
      if (types.length != 1) {
        return;
      }

      final type = types.single;
      final expected = expectedFileNameForType(type.name.lexeme);
      final actual = fileBasename(resolver.path);
      if (actual == expected) {
        return;
      }

      reporter.atToken(type.name, code);
    });
  }
}
