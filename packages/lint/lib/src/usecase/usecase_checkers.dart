import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_layered_architecture_lint/src/ast_compat.dart';
import 'package:meta/meta.dart';

/// [node] に `@usecase` / `@Usecase()` が付いているかを判定する.
///
/// 名前解決前の AST 上で、アノテーション識別子が `usecase` または `Usecase` かを見る.
///
/// Example:
/// ```dart
/// context.registry.addClassDeclaration((node) {
///   if (!hasUsecaseAnnotation(node)) {
///     return;
///   }
/// });
/// ```
@internal
bool hasUsecaseAnnotation(AnnotatedNode node) {
  for (final annotation in node.metadata) {
    final name = annotation.name;
    final simpleName = switch (name) {
      PrefixedIdentifier(:final identifier) => identifier.name,
      SimpleIdentifier(:final name) => name,
    };
    if (simpleName == 'usecase' || simpleName == 'Usecase') {
      return true;
    }
  }
  return false;
}

/// [node] が持つインスタンスメソッド宣言を列挙する.
///
/// static・getter・setter は除外する.
///
/// Example:
/// ```dart
/// final methods = instanceMethodsOf(classNode).toList();
/// ```
@internal
Iterable<MethodDeclaration> instanceMethodsOf(ClassDeclaration node) {
  return classDeclarationMembers(node).whereType<MethodDeclaration>().where(
    (method) => !method.isStatic && !method.isGetter && !method.isSetter,
  );
}

/// [node] が持つ public インスタンスメソッド宣言を列挙する.
///
/// [instanceMethodsOf] のうち、名前が `_` で始まらないもの.
///
/// Example:
/// ```dart
/// final publics = publicInstanceMethodsOf(classNode).toList();
/// ```
@internal
Iterable<MethodDeclaration> publicInstanceMethodsOf(ClassDeclaration node) {
  return instanceMethodsOf(node).where(
    (method) => !method.name.lexeme.startsWith('_'),
  );
}
