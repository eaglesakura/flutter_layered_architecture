import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
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
final class PublicTypeFileName extends AnalysisRule {
  /// [PublicTypeFileName] の診断コード.
  static const LintCode code = LintCode(
    'public_type_file_name',
    'The file name must be the lower_snake_case form of the single public '
        'type name.',
    severity: architectureViolationSeverity,
  );

  /// [PublicTypeFileName] ルールを生成する.
  PublicTypeFileName()
    : super(
        name: 'public_type_file_name',
        description:
            'The file name must be the lower_snake_case form of the single '
            'public type name.',
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

  final PublicTypeFileName rule;
  final RuleContext context;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final path = context.currentUnit?.file.path ?? '';
    if (shouldSkipFileLayoutLint(path: path, unit: node)) {
      return;
    }

    final types = publicNamedTypesOf(node).toList(growable: false);
    if (types.length != 1) {
      return;
    }

    final type = types.single;
    final expected = expectedFileNameForType(type.name.lexeme);
    final actual = fileBasename(path);
    if (actual == expected) {
      return;
    }

    rule.reportAtToken(type.name);
  }
}
