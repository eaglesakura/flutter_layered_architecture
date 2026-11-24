import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/file_layout/file_layout_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/file_layout/public_api_checkers.dart';
import 'package:meta/meta.dart';

/// バレルに載っていない公開トップレベルシンボルへ `@internal` を強制する Lint.
///
/// 公開面は `lib/` 直下の `library;` 付きファイルの `exportNamespace`.
/// バレルが無いパッケージはスキップする. `part of` / `test/` は対象外.
///
/// Example:
/// ```dart
/// // lib/src/hidden.dart（バレル未 export）
/// // final class Hidden {}
/// // → unexported_public_must_be_internal
/// ```
@internal
final class UnexportedPublicMustBeInternal extends DartLintRule {
  /// [UnexportedPublicMustBeInternal] の診断コード.
  static const _code = LintCode(
    name: 'unexported_public_must_be_internal',
    problemMessage:
        'Public symbols not exported from a lib/ barrel (library;) '
        'must be annotated with @internal or be private.',
    errorSeverity: architectureViolationSeverity,
  );

  /// [UnexportedPublicMustBeInternal] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = UnexportedPublicMustBeInternal();
  /// ```
  const UnexportedPublicMustBeInternal() : super(code: _code);

  /// 未 export の公開シンボルに `@internal` が無ければ報告する.
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

      final snapshot = barrelExportSnapshotOf(resolver, context);
      if (snapshot == null || !snapshot.hasBarrels) {
        return;
      }

      for (final symbol in publicTopLevelSymbolsOf(unit)) {
        if (isExportedNameInBarrels(symbol.name.lexeme, snapshot)) {
          continue;
        }
        if (hasInternalAnnotation(symbol.annotated)) {
          continue;
        }
        reporter.atToken(symbol.name, code);
      }
    });
  }

  /// バレル公開面をキャッシュしてから親の startUp を実行する.
  ///
  /// [resolver] は解析対象ファイルの解決情報.
  /// [context] は共有状態と AST 登録に使う.
  ///
  /// Example:
  /// ```dart
  /// await rule.startUp(resolver, context);
  /// ```
  @override
  Future<void> startUp(
    CustomLintResolver resolver,
    CustomLintContext context,
  ) async {
    cacheBarrelExportsIfNeeded(resolver, context);
    await super.startUp(resolver, context);
  }
}
