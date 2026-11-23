import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

export 'package:flutter_layered_architecture_lint/src/delegate/delegate_checkers.dart'
    show fieldsAreFinalOrConst, hasConstConstructor;

/// `state_stream` の `MutableStateStream` 型チェッカー.
const mutableStateStreamChecker = TypeChecker.fromName(
  'MutableStateStream',
  packageName: 'state_stream',
);

/// [node] 内で `MutableStateStream.close()` が呼ばれているかを判定する.
///
/// Example:
/// ```dart
/// final closes = callsMutableStateStreamClose(classNode);
/// ```
bool callsMutableStateStreamClose(ClassDeclaration node) {
  final visitor = _MutableStateStreamCloseVisitor();
  node.accept(visitor);
  return visitor.found;
}

/// [node] が `MutableStateStream` 型のフィールドを1つ以上持つかを判定する.
///
/// Example:
/// ```dart
/// final hasStream = hasMutableStateStreamField(classNode);
/// ```
bool hasMutableStateStreamField(ClassDeclaration node) {
  return mutableStateStreamFieldsOf(node).isNotEmpty;
}

/// [node] に `@stateful` / `@Stateful()` が付いているかを判定する.
///
/// Example:
/// ```dart
/// if (!hasStatefulAnnotation(classNode)) {
///   return;
/// }
/// ```
bool hasStatefulAnnotation(AnnotatedNode node) {
  for (final annotation in node.metadata) {
    final name = annotation.name;
    final simpleName = switch (name) {
      SimpleIdentifier(:final name) => name,
      PrefixedIdentifier(:final identifier) => identifier.name,
      _ => name.toSource(),
    };
    if (simpleName == 'stateful' || simpleName == 'Stateful') {
      return true;
    }
  }
  return false;
}

/// [node] 内の `MutableStateStream` 型フィールド宣言を列挙する.
///
/// Example:
/// ```dart
/// final fields = mutableStateStreamFieldsOf(classNode);
/// ```
Iterable<VariableDeclaration> mutableStateStreamFieldsOf(
  ClassDeclaration node,
) sync* {
  for (final field in node.members.whereType<FieldDeclaration>()) {
    for (final variable in field.fields.variables) {
      final type = _resolvedFieldType(field, variable);
      if (type != null &&
          mutableStateStreamChecker.isAssignableFromType(type)) {
        yield variable;
      }
    }
  }
}

DartType? _resolvedFieldType(
  FieldDeclaration field,
  VariableDeclaration variable,
) {
  final fromElement = variable.declaredFragment?.element.type;
  if (fromElement != null) {
    return fromElement;
  }
  return field.fields.type?.type;
}

/// `MutableStateStream.close()` 呼び出しを検出する Visitor.
final class _MutableStateStreamCloseVisitor extends RecursiveAstVisitor<void> {
  /// 検出済みなら true.
  bool found = false;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (found) {
      return;
    }
    if (node.methodName.name == 'close') {
      final targetType = node.realTarget?.staticType;
      if (targetType != null &&
          mutableStateStreamChecker.isAssignableFromType(targetType)) {
        found = true;
        return;
      }
    }
    super.visitMethodInvocation(node);
  }
}
