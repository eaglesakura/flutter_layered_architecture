import 'package:analyzer/dart/ast/ast.dart';

export 'package:flutter_layered_architecture_lint/src/usecase/usecase_checkers.dart'
    show instanceMethodsOf;

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
bool hasInternalAnnotation(AnnotatedNode node) {
  return _hasAnnotationNamed(node, {'internal', 'Internal'});
}

/// [node] のフィールドがすべて `final` または `const` かを判定する.
///
/// Example:
/// ```dart
/// final ok = fieldsAreFinalOrConst(classNode);
/// ```
bool fieldsAreFinalOrConst(ClassDeclaration node) {
  return node.members.whereType<FieldDeclaration>().every(
    (field) => field.fields.isFinal || field.fields.isConst,
  );
}

/// [node] が `const` コンストラクタを1つ以上持つかを判定する.
///
/// Example:
/// ```dart
/// final ok = hasConstConstructor(classNode);
/// ```
bool hasConstConstructor(ClassDeclaration node) {
  return node.members.whereType<ConstructorDeclaration>().any(
    (constructor) => constructor.constKeyword != null,
  );
}

bool _hasAnnotationNamed(AnnotatedNode node, Set<String> names) {
  for (final annotation in node.metadata) {
    final name = annotation.name;
    final simpleName = switch (name) {
      SimpleIdentifier(:final name) => name,
      PrefixedIdentifier(:final identifier) => identifier.name,
      _ => name.toSource(),
    };
    if (names.contains(simpleName)) {
      return true;
    }
  }
  return false;
}
