import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:flutter_layered_architecture_lint/src/ast_compat.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_type_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/stateful/stateful_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/usecase/usecase_checkers.dart'

    show instanceMethodsOf;
import 'package:flutter_layered_architecture_lint/src/view_model/view_model_checkers.dart';
import 'package:meta/meta.dart';

/// [node] 配下で `MutableStateStream.close()` が呼ばれるかを判定する.
///
/// Example:
/// ```dart
/// final closes = callsMutableStateStreamCloseIn(method);
/// ```
@internal
bool callsMutableStateStreamCloseIn(AstNode node) {
  final visitor = _MutableStateStreamCloseOnlyVisitor();
  node.accept(visitor);
  return visitor.foundClose && !visitor.foundOtherInvocation;
}

bool _callsDelegateExecute(MethodDeclaration method) {
  final visitor = _DelegateExecuteVisitor();
  method.accept(visitor);
  return visitor.found;
}

bool _isCloseOnlyMethod(MethodDeclaration method) {
  final name = method.name.lexeme;
  if (name != 'close' && name != '_close') {
    return false;
  }
  return callsMutableStateStreamCloseIn(method);
}

/// `@stateful` / `@viewModel` のインスタンスメソッドが `@delegate` へ委譲されることを検証する Lint.
///
/// 業務処理は Delegate の `execute` 呼び出しに分離する.
/// `close` / `_close` で `MutableStateStream.close()` のみ行うメソッドは例外とする.
/// 当該型への extension method も同様に検査する.
///
/// Example:
/// ```dart
/// // @stateful
/// // final class Bad {
/// //   const Bad({required this.state});
/// //   final MutableStateStream<FooState> state;
/// //   Future<void> doWork() async { /* 直接ロジック */ }
/// // }
/// // → stateful_methods_use_delegate
/// ```
@internal
final class StatefulMethodsUseDelegate extends AnalysisRule {
  /// [StatefulMethodsUseDelegate] の診断コード.
  static const LintCode code = LintCode(
    'stateful_methods_use_delegate',
    '@stateful/@viewModel instance methods must delegate to a @delegate '
        'execute method (close/_close that only closes MutableStateStream is '
        'allowed).',
    severity: architectureViolationSeverity,
  );

  /// [StatefulMethodsUseDelegate] ルールを生成する.
  StatefulMethodsUseDelegate()
    : super(
        name: 'stateful_methods_use_delegate',
        description:
            '@stateful/@viewModel instance methods must delegate to a '
            '@delegate execute method (close/_close that only closes '
            'MutableStateStream is allowed).',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addClassDeclaration(this, _ClassVisitor(this));
    registry.addExtensionDeclaration(this, _ExtensionVisitor(this));
  }
}

final class _ClassVisitor extends SimpleAstVisitor<void> {
  _ClassVisitor(this.rule);

  final StatefulMethodsUseDelegate rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!appliesStatefulRules(node)) {
      return;
    }

    for (final method in instanceMethodsOf(node)) {
      _reportIfMissingDelegate(method);
    }
  }

  void _reportIfMissingDelegate(MethodDeclaration method) {
    if (_isCloseOnlyMethod(method)) {
      return;
    }
    if (_callsDelegateExecute(method)) {
      return;
    }
    rule.reportAtToken(method.name);
  }
}

final class _ExtensionVisitor extends SimpleAstVisitor<void> {
  _ExtensionVisitor(this.rule);

  final StatefulMethodsUseDelegate rule;

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    final extendedType = extensionExtendedType(node);
    if (!typeAppliesStatefulRules(extendedType)) {
      return;
    }

    for (final method in extensionDeclarationMembers(node).whereType<MethodDeclaration>()) {
      if (method.isStatic || method.isGetter || method.isSetter) {
        continue;
      }
      if (_isCloseOnlyMethod(method)) {
        continue;
      }
      if (_callsDelegateExecute(method)) {
        continue;
      }
      rule.reportAtToken(method.name);
    }
  }
}

final class _DelegateExecuteVisitor extends RecursiveAstVisitor<void> {
  /// `@delegate` 型への `execute` 呼び出しを検出したか.
  bool found = false;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (found) {
      return;
    }
    if (node.methodName.name == 'execute') {
      final receiverType = node.realTarget?.staticType;
      if (typeHasAnnotation(receiverType, delegateAnnotationChecker)) {
        found = true;
        return;
      }
    }
    super.visitMethodInvocation(node);
  }
}

final class _MutableStateStreamCloseOnlyVisitor
    extends RecursiveAstVisitor<void> {
  /// `MutableStateStream.close()` を検出したか.
  bool foundClose = false;

  /// close 以外のメソッド呼び出しを検出したか.
  bool foundOtherInvocation = false;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'close') {
      final targetType = node.realTarget?.staticType;
      if (targetType != null &&
          mutableStateStreamChecker.isAssignableFromType(targetType)) {
        foundClose = true;
        super.visitMethodInvocation(node);
        return;
      }
    }
    foundOtherInvocation = true;
    super.visitMethodInvocation(node);
  }
}
