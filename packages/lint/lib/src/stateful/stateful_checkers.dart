import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:flutter_layered_architecture_lint/src/ast_compat.dart';
import 'package:flutter_layered_architecture_lint/src/type_checker.dart';
import 'package:meta/meta.dart';

export 'package:flutter_layered_architecture_lint/src/delegate/delegate_checkers.dart'
    show fieldsAreFinalOrConst, hasConstConstructor;

/// `freezed_annotation` の Freezed アノテーション型チェッカー.
@internal
const freezedAnnotationChecker = TypeChecker.fromName(
  'Freezed',
  packageName: 'freezed_annotation',
);

/// `state_stream` の `MutableStateStream` 型チェッカー.
@internal
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
@internal
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
@internal
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
@internal
bool hasStatefulAnnotation(AnnotatedNode node) {
  return _hasAnnotationNamed(node, {'stateful', 'Stateful'});
}

/// [node] に `@viewModel` / `@ViewModel()` が付いているかを判定する.
///
/// Example:
/// ```dart
/// if (!hasViewModelAnnotation(classNode)) {
///   return;
/// }
/// ```
@internal
bool hasViewModelAnnotation(AnnotatedNode node) {
  return _hasAnnotationNamed(node, {'viewModel', 'ViewModel'});
}

/// `@stateful` または `@viewModel` の対象かを判定する.
///
/// `@viewModel` は `@stateful` の制約を引き継ぐ.
///
/// Example:
/// ```dart
/// if (!appliesStatefulRules(classNode)) {
///   return;
/// }
/// ```
@internal
bool appliesStatefulRules(AnnotatedNode node) {
  return hasStatefulAnnotation(node) || hasViewModelAnnotation(node);
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

/// [type] が Freezed（`@freezed` / `@Freezed()`）付きクラスかを判定する.
///
/// Example:
/// ```dart
/// final ok = isFreezedAnnotatedType(stateType);
/// ```
@internal
bool isFreezedAnnotatedType(DartType? type) {
  if (type is! InterfaceType) {
    return false;
  }
  return freezedAnnotationChecker.hasAnnotationOf(
    type.element,
    throwOnUnresolved: false,
  );
}

/// [node] 内の `MutableStateStream` 型フィールド宣言を列挙する.
///
/// Example:
/// ```dart
/// final fields = mutableStateStreamFieldsOf(classNode);
/// ```
@internal
Iterable<VariableDeclaration> mutableStateStreamFieldsOf(
  ClassDeclaration node,
) sync* {
  for (final field in classDeclarationMembers(
    node,
  ).whereType<FieldDeclaration>()) {
    for (final variable in field.fields.variables) {
      final type = _resolvedFieldType(field, variable);
      if (type != null &&
          mutableStateStreamChecker.isAssignableFromType(type)) {
        yield variable;
      }
    }
  }
}

/// [streamType] が `MutableStateStream<T>` のときの型引数 `T` を返す.
///
/// Example:
/// ```dart
/// final stateType = mutableStateStreamStateType(fieldType);
/// ```
@internal
DartType? mutableStateStreamStateType(DartType? streamType) {
  if (streamType is! InterfaceType) {
    return null;
  }
  if (!mutableStateStreamChecker.isAssignableFromType(streamType)) {
    return null;
  }
  if (streamType.typeArguments.isEmpty) {
    return null;
  }
  return streamType.typeArguments.first;
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
