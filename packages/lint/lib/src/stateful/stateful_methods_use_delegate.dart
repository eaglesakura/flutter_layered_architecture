import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_type_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/stateful/stateful_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/usecase/usecase_checkers.dart';

/// [node] 配下で `MutableStateStream.close()` が呼ばれるかを判定する.
///
/// Example:
/// ```dart
/// final closes = callsMutableStateStreamCloseIn(method);
/// ```
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

/// `@stateful` のインスタンスメソッドが `@delegate` へ委譲されることを検証する Lint.
///
/// 業務処理は Delegate の `execute` 呼び出しに分離する.
/// `close` / `_close` で `MutableStateStream.close()` のみ行うメソッドは例外とする.
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
final class StatefulMethodsUseDelegate extends DartLintRule {
  /// [StatefulMethodsUseDelegate] の診断コード.
  static const _code = LintCode(
    name: 'stateful_methods_use_delegate',
    problemMessage:
        '@stateful instance methods must delegate to a @delegate execute '
        'method (close/_close that only closes MutableStateStream is allowed).',
  );

  /// [StatefulMethodsUseDelegate] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = StatefulMethodsUseDelegate();
  /// ```
  const StatefulMethodsUseDelegate() : super(code: _code);

  /// `@stateful` の各インスタンスメソッドを検査し、委譲が無ければ報告する.
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
      if (!hasStatefulAnnotation(node)) {
        return;
      }

      for (final method in instanceMethodsOf(node)) {
        if (_isCloseOnlyMethod(method)) {
          continue;
        }
        if (_callsDelegateExecute(method)) {
          continue;
        }
        reporter.atToken(method.name, code);
      }
    });
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
