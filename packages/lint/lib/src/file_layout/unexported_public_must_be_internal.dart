import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
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
final class UnexportedPublicMustBeInternal extends AnalysisRule {
  /// [UnexportedPublicMustBeInternal] の診断コード.
  static const LintCode code = LintCode(
    'unexported_public_must_be_internal',
    'Public symbols not exported from a lib/ barrel (library;) must be '
        'annotated with @internal or be private.',
    severity: architectureViolationSeverity,
  );

  /// [UnexportedPublicMustBeInternal] ルールを生成する.
  UnexportedPublicMustBeInternal()
    : super(
        name: 'unexported_public_must_be_internal',
        description:
            'Public symbols not exported from a lib/ barrel (library;) must '
            'be annotated with @internal or be private.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addCompilationUnit(this, _Visitor(this, context));
  }
}

final class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final UnexportedPublicMustBeInternal rule;
  final RuleContext context;

  @override
  void visitCompilationUnit(CompilationUnit unit) {
    final path = context.currentUnit?.file.path ?? '';
    if (shouldSkipFileLayoutLint(path: path, unit: unit)) {
      return;
    }

    final packageName = packageNameForContext(context, path);
    final snapshot = barrelSnapshotForPath(path, packageName);
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
      rule.reportAtToken(symbol.name);
    }
  }
}
