import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/file_layout/file_layout_checkers.dart';
import 'package:meta/meta.dart';

/// 1ファイルに public な名前付き型が2つ以上ないことを検証する Lint.
///
/// `part of` と `test/` 配下は対象外.
/// private（`_` 始まり）と typedef・無名 extension は件数に含めない.
///
/// Example:
/// ```dart
/// // final class Foo {}
/// // final class Bar {}
/// // → one_public_type_per_file (on Bar)
/// ```
@internal
final class OnePublicTypePerFile extends DartLintRule {
  /// [OnePublicTypePerFile] の診断コード.
  static const _code = LintCode(
    name: 'one_public_type_per_file',
    problemMessage:
        'A file must declare at most one public named type '
        '(class/enum/mixin/extension/extension type).',
    errorSeverity: architectureViolationSeverity,
  );

  /// [OnePublicTypePerFile] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = OnePublicTypePerFile();
  /// ```
  const OnePublicTypePerFile() : super(code: _code);

  /// コンパイル単位を走査し、public 型が2つ以上なら2つ目以降を報告する.
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
      if (types.length < 2) {
        return;
      }

      for (final type in types.skip(1)) {
        reporter.atToken(type.name, code);
      }
    });
  }
}
