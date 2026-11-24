import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_layered_architecture_lint/src/ast_compat.dart';
import 'package:meta/meta.dart';

export 'package:flutter_layered_architecture_lint/src/usecase/usecase_checkers.dart'
    show instanceMethodsOf;

/// [node] のフィールドがすべて `final` または `const` かを判定する.
///
/// Example:
/// ```dart
/// final ok = fieldsAreFinalOrConst(classNode);
/// ```
@internal
bool fieldsAreFinalOrConst(ClassDeclaration node) {
  return classDeclarationMembers(node).whereType<FieldDeclaration>().every(
    (field) => field.fields.isFinal || field.fields.isConst,
  );
}

/// [node] が `const` コンストラクタを1つ以上持つかを判定する.
///
/// Example:
/// ```dart
/// final ok = hasConstConstructor(classNode);
/// ```
@internal
bool hasConstConstructor(ClassDeclaration node) {
  return classDeclarationMembers(node).whereType<ConstructorDeclaration>().any(
    (constructor) => constructor.constKeyword != null,
  );
}

/// [node] に `@delegate` / `@Delegate()` が付いているかを判定する.
///
/// 名前解決前の AST 上で、アノテーション識別子が `delegate` または `Delegate` かを見る.
///
/// Example:
/// ```dart
/// context.registry.addClassDeclaration((node) {
///   if (!hasDelegateAnnotation(node)) {
///     return;
///   }
/// });
/// ```
@internal
bool hasDelegateAnnotation(AnnotatedNode node) {
  return _hasAnnotationNamed(node, {'delegate', 'Delegate'});
}

/// [node] に `@internal` / `@Internal()` が付いているかを判定する.
///
/// Example:
/// ```dart
/// if (!hasInternalAnnotation(classNode)) {
///   reporter.atToken(classNode.name, code);
/// }
/// ```
@internal
bool hasInternalAnnotation(AnnotatedNode node) {
  return _hasAnnotationNamed(node, {'internal', 'Internal'});
}

bool _hasAnnotationNamed(AnnotatedNode node, Set<String> names) {
  for (final annotation in node.metadata) {
    final name = annotation.name;
    final simpleName = switch (name) {
      PrefixedIdentifier(:final identifier) => identifier.name,
      SimpleIdentifier(:final name) => name,
    };
    if (names.contains(simpleName)) {
      return true;
    }
  }
  return false;
}
