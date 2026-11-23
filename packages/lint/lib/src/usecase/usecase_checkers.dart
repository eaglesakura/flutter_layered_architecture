import 'package:analyzer/dart/ast/ast.dart';

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
bool hasUsecaseAnnotation(AnnotatedNode node) {
  for (final annotation in node.metadata) {
    final name = annotation.name;
    final simpleName = switch (name) {
      SimpleIdentifier(:final name) => name,
      PrefixedIdentifier(:final identifier) => identifier.name,
      _ => name.toSource(),
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
Iterable<MethodDeclaration> instanceMethodsOf(ClassDeclaration node) {
  return node.members.whereType<MethodDeclaration>().where(
    (method) => !method.isStatic && !method.isGetter && !method.isSetter,
  );
}
