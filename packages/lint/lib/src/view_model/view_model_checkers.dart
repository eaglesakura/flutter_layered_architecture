import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_type_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/stateful/stateful_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/usecase/usecase_checkers.dart';
import 'package:meta/meta.dart';

export 'package:flutter_layered_architecture_lint/src/delegate/delegate_checkers.dart'
    show hasInternalAnnotation;
export 'package:flutter_layered_architecture_lint/src/stateful/stateful_checkers.dart'
    show
        appliesStatefulRules,
        hasViewModelAnnotation,
        isFreezedAnnotatedType,
        mutableStateStreamFieldsOf,
        mutableStateStreamStateType;

/// `@Stateful` アノテーションの型チェッカー.
@internal
const statefulAnnotationChecker = TypeChecker.fromName(
  'Stateful',
  packageName: 'flutter_layered_architecture_annotations',
);

/// `state_stream` の `StateStream` 型チェッカー.
@internal
const stateStreamChecker = TypeChecker.fromName(
  'StateStream',
  packageName: 'state_stream',
);

/// `@ViewModel` アノテーションの型チェッカー.
@internal
const viewModelAnnotationChecker = TypeChecker.fromName(
  'ViewModel',
  packageName: 'flutter_layered_architecture_annotations',
);

/// [node] の `entity` getter 宣言を返す.
///
/// Example:
/// ```dart
/// final getter = entityGetterOf(classNode);
/// ```
@internal
MethodDeclaration? entityGetterOf(ClassDeclaration node) {
  for (final method in node.members.whereType<MethodDeclaration>()) {
    if (method.isGetter && method.name.lexeme == 'entity') {
      return method;
    }
  }
  return null;
}

/// [node] の `entity` getter が返す `StateStream<T>` の `T` を返す.
///
/// Example:
/// ```dart
/// final entityType = entityModelTypeOf(classNode);
/// ```
@internal
DartType? entityModelTypeOf(ClassDeclaration node) {
  final getter = entityGetterOf(node);
  if (getter == null) {
    return null;
  }
  return stateStreamTypeArgument(getter.returnType?.type);
}

/// [node] の `on` 句の拡張対象型を返す.
///
/// Example:
/// ```dart
/// final type = extensionExtendedType(extensionNode);
/// ```
@internal
DartType? extensionExtendedType(ExtensionDeclaration node) {
  return node.onClause?.extendedType.type;
}

/// [node]（extension）のインスタンスメソッドのうち命名違反を列挙する.
///
/// Example:
/// ```dart
/// for (final method in extensionMethodsWithInvalidNames(extensionNode)) {
///   reporter.atToken(method.name, code);
/// }
/// ```
@internal
Iterable<MethodDeclaration> extensionMethodsWithInvalidNames(
  ExtensionDeclaration node,
) {
  return node.members.whereType<MethodDeclaration>().where(
    (method) =>
        !method.isStatic &&
        !method.isGetter &&
        !method.isSetter &&
        !isAllowedViewModelMethodName(method),
  );
}

/// [node] が `StateStream<T> get entity` を持つかを判定する.
///
/// Example:
/// ```dart
/// if (!hasEntityStateStreamGetter(classNode)) {
///   reporter.atToken(classNode.name, code);
/// }
/// ```
@internal
bool hasEntityStateStreamGetter(ClassDeclaration node) {
  final getter = entityGetterOf(node);
  if (getter == null) {
    return false;
  }
  final resolved = getter.returnType?.type;
  if (resolved != null && stateStreamChecker.isAssignableFromType(resolved)) {
    return true;
  }
  final returnType = getter.returnType;
  return returnType is NamedType && returnType.name.lexeme == 'StateStream';
}

/// 2つの型が同じ interface 要素かを判定する.
///
/// Example:
/// ```dart
/// if (interfaceTypesAreSame(entityType, stateType)) {
///   // entity と state が同一モデル
/// }
/// ```
@internal
bool interfaceTypesAreSame(DartType? left, DartType? right) {
  if (left is! InterfaceType || right is! InterfaceType) {
    return false;
  }
  return left.element == right.element;
}

/// [method] が ViewModel の命名規則（`on*` / `close` / `_close`）に合うかを判定する.
///
/// Example:
/// ```dart
/// if (!isAllowedViewModelMethodName(method)) {
///   reporter.atToken(method.name, code);
/// }
/// ```
@internal
bool isAllowedViewModelMethodName(MethodDeclaration method) {
  final name = method.name.lexeme;
  return isCloseMethodName(name) || isOnActionMethodName(name);
}

/// [name] が `close` / `_close` かを判定する.
///
/// Example:
/// ```dart
/// if (isCloseMethodName(method.name.lexeme)) {
///   continue;
/// }
/// ```
@internal
bool isCloseMethodName(String name) => name == 'close' || name == '_close';

/// [name] が `on` で始まる ViewModel アクション名かを判定する.
///
/// Example:
/// ```dart
/// isOnActionMethodName('onInitialize'); // true
/// isOnActionMethodName('doWork'); // false
/// ```
@internal
bool isOnActionMethodName(String name) => name.startsWith('on');

/// [node] の最初の `MutableStateStream<T>` フィールドの `T` を返す.
///
/// Example:
/// ```dart
/// final stateType = primaryStateModelTypeOf(classNode);
/// ```
@internal
DartType? primaryStateModelTypeOf(ClassDeclaration node) {
  for (final variable in mutableStateStreamFieldsOf(node)) {
    final streamType = variable.declaredFragment?.element.type;
    final stateType = mutableStateStreamStateType(streamType);
    if (stateType != null) {
      return stateType;
    }
  }
  return null;
}

/// [streamType] が `StateStream<T>`（またはその subtype）のときの型引数 `T` を返す.
///
/// Example:
/// ```dart
/// final entityType = stateStreamTypeArgument(getter.returnType?.type);
/// ```
@internal
DartType? stateStreamTypeArgument(DartType? streamType) {
  if (streamType is! InterfaceType) {
    return null;
  }
  if (!stateStreamChecker.isAssignableFromType(streamType)) {
    return null;
  }

  if (stateStreamChecker.isExactlyType(streamType) &&
      streamType.typeArguments.isNotEmpty) {
    return streamType.typeArguments.first;
  }

  for (final superType in streamType.allSupertypes) {
    if (stateStreamChecker.isExactlyType(superType) &&
        superType.typeArguments.isNotEmpty) {
      return superType.typeArguments.first;
    }
  }

  if (streamType.typeArguments.isNotEmpty) {
    return streamType.typeArguments.first;
  }
  return null;
}

/// [type] が `@stateful` / `@viewModel` 対象かを判定する.
///
/// Example:
/// ```dart
/// if (!typeAppliesStatefulRules(extendedType)) {
///   return;
/// }
/// ```
@internal
bool typeAppliesStatefulRules(DartType? type) {
  return typeHasAnnotation(type, viewModelAnnotationChecker) ||
      typeHasAnnotation(type, statefulAnnotationChecker);
}

/// [type] が `@viewModel` 対象かを判定する.
///
/// Example:
/// ```dart
/// if (!typeHasViewModelAnnotation(extendedType)) {
///   return;
/// }
/// ```
@internal
bool typeHasViewModelAnnotation(DartType? type) {
  return typeHasAnnotation(type, viewModelAnnotationChecker);
}

/// [node] のインスタンスメソッドのうち命名違反を列挙する.
///
/// getter / setter / static は対象外.
///
/// Example:
/// ```dart
/// for (final method in viewModelMethodsWithInvalidNames(classNode)) {
///   reporter.atToken(method.name, code);
/// }
/// ```
@internal
Iterable<MethodDeclaration> viewModelMethodsWithInvalidNames(
  ClassDeclaration node,
) {
  return instanceMethodsOf(node).where(
    (method) => !isAllowedViewModelMethodName(method),
  );
}
