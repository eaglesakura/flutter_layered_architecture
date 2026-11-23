import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/usecase/usecase_checkers.dart';

/// `@usecase` の唯一のインスタンスメソッドが引数と非 void 戻り値を持つことを検証する Lint.
///
/// インスタンスメソッドがちょうど1つのときだけシグネチャを検査する.
/// メソッド数の過不足は `usecase_single_method` ルール側で扱う.
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
final class UsecaseMethodSignature extends DartLintRule {
  /// [UsecaseMethodSignature] の診断コード.
  static const _code = LintCode(
    name: 'usecase_method_signature',
    problemMessage:
        '@usecase methods must have at least one parameter and a non-void '
        'return type.',
  );

  /// [UsecaseMethodSignature] ルールを生成する.
  ///
  /// Example:
  /// ```dart
  /// const rule = UsecaseMethodSignature();
  /// ```
  const UsecaseMethodSignature() : super(code: _code);

  /// `@usecase` クラスの唯一のインスタンスメソッドを検査し、違反なら報告する.
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
      if (!hasUsecaseAnnotation(node)) {
        return;
      }

      final methods = instanceMethodsOf(node).toList(growable: false);
      if (methods.length != 1) {
        return;
      }

      final method = methods.single;
      final parameterList = method.parameters;
      final hasParameters =
          parameterList != null && parameterList.parameters.isNotEmpty;
      final hasReturnValue = !_isVoidReturnType(method.returnType);
      if (hasParameters && hasReturnValue) {
        return;
      }

      reporter.atToken(method.name, code);
    });
  }

  /// [returnType] が void（または戻り値注釈なし）かを判定する.
  ///
  /// 注釈が無い場合は暗黙の void 扱いとする.
  ///
  /// Example:
  /// ```dart
  /// final isVoid = _isVoidReturnType(method.returnType);
  /// ```
  bool _isVoidReturnType(TypeAnnotation? returnType) {
    if (returnType == null) {
      return true;
    }
    if (returnType is NamedType) {
      return returnType.name.lexeme == 'void';
    }
    return returnType.toSource() == 'void';
  }
}
