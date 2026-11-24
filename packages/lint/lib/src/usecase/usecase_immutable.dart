import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/ast_compat.dart';
import 'package:flutter_layered_architecture_lint/src/usecase/usecase_checkers.dart';
import 'package:meta/meta.dart';

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
@internal
final class UsecaseImmutable extends AnalysisRule {
  /// [UsecaseImmutable] の診断コード.
  static const LintCode code = LintCode(
    'usecase_immutable',
    '@usecase types must have only final fields and at least one const '
        'constructor.',
    severity: architectureViolationSeverity,
  );

  /// [UsecaseImmutable] ルールを生成する.
  UsecaseImmutable()
    : super(
        name: 'usecase_immutable',
        description:
            '@usecase types must have only final fields and at least one '
            'const constructor.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addClassDeclaration(this, _Visitor(this));
  }
}

final class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final UsecaseImmutable rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!hasUsecaseAnnotation(node)) {
      return;
    }

    final fieldsAreFinal = classDeclarationMembers(node).whereType<FieldDeclaration>().every(
      (field) => field.fields.isFinal || field.fields.isConst,
    );
    final hasConstConstructor = classDeclarationMembers(node)
        .whereType<ConstructorDeclaration>()
        .any((constructor) => constructor.constKeyword != null);

    if (fieldsAreFinal && hasConstConstructor) {
      return;
    }

    rule.reportAtToken(classDeclarationName(node));
  }
}
