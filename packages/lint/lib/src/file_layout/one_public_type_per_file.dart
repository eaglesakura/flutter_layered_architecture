import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/file_layout/file_layout_checkers.dart';
import 'package:meta/meta.dart';

/// 1ファイルに public な名前付き型が2つ以上ないことを検証する Lint.
///
/// `part of` と `test/` 配下は対象外.
/// private（`_` 始まり）と typedef・無名 extension は件数に含めない.
@internal
final class OnePublicTypePerFile extends AnalysisRule {
  /// [OnePublicTypePerFile] の診断コード.
  static const LintCode code = LintCode(
    'one_public_type_per_file',
    'A file must declare at most one public named type '
        '(class/enum/mixin/extension/extension type).',
    severity: architectureViolationSeverity,
  );

  /// [OnePublicTypePerFile] ルールを生成する.
  OnePublicTypePerFile()
    : super(
        name: 'one_public_type_per_file',
        description:
            'A file must declare at most one public named type '
            '(class/enum/mixin/extension/extension type).',
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
  final OnePublicTypePerFile rule;

  final RuleContext context;
  _Visitor(this.rule, this.context);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final path = context.currentUnit?.file.path ?? '';
    if (shouldSkipFileLayoutLint(path: path, unit: node)) {
      return;
    }

    final types = publicNamedTypesOf(node).toList(growable: false);
    if (types.length < 2) {
      return;
    }

    for (final type in types.skip(1)) {
      rule.reportAtToken(type.name);
    }
  }
}
