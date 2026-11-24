import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/usecase/usecase_checkers.dart';
import 'package:meta/meta.dart';

/// `@usecase` の唯一の public インスタンスメソッドが引数と非 void 戻り値を持つことを検証する Lint.
///
/// public インスタンスメソッドがちょうど1つのときだけシグネチャを検査する.
/// public メソッドが2つ以上の場合は `usecase_single_method` ルール側で扱う.
///
/// Example:
/// ```dart
/// // @usecase
/// // final class Bad {
/// //   const Bad();
/// //   void execute() {}
/// // }
/// // → usecase_method_signature
/// ```
@internal
final class UsecaseMethodSignature extends AnalysisRule {
  /// [UsecaseMethodSignature] の診断コード.
  static const LintCode code = LintCode(
    'usecase_method_signature',
    '@usecase methods must have at least one parameter and a non-void return '
        'type.',
    severity: architectureViolationSeverity,
  );

  /// [UsecaseMethodSignature] ルールを生成する.
  UsecaseMethodSignature()
    : super(
        name: 'usecase_method_signature',
        description:
            '@usecase methods must have at least one parameter and a non-void '
            'return type.',
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

  final UsecaseMethodSignature rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!hasUsecaseAnnotation(node)) {
      return;
    }

    final methods = publicInstanceMethodsOf(node).toList(growable: false);
    if (methods.length != 1) {
      return;
    }

    final method = methods.single;
    final parameterList = method.parameters;
    final hasParameters =
        parameterList != null && parameterList.parameters.isNotEmpty;
    final hasReturnValue = !isVoidReturnType(method.returnType);
    if (hasParameters && hasReturnValue) {
      return;
    }

    rule.reportAtToken(method.name);
  }
}

/// [returnType] が void（または戻り値注釈なし）かを判定する.
@internal
bool isVoidReturnType(TypeAnnotation? returnType) {
  if (returnType == null) {
    return true;
  }
  if (returnType is NamedType) {
    return returnType.name.lexeme == 'void';
  }
  return returnType.toSource() == 'void';
}
