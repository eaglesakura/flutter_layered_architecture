import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:flutter_layered_architecture_lint/src/type_checker.dart';
import 'package:meta/meta.dart';

/// `@Delegate` アノテーションの型チェッカー.
@internal
const delegateAnnotationChecker = TypeChecker.fromName(
  'Delegate',
  packageName: 'flutter_layered_architecture_annotations',
);

/// `@Usecase` アノテーションの型チェッカー.
@internal
const usecaseAnnotationChecker = TypeChecker.fromName(
  'Usecase',
  packageName: 'flutter_layered_architecture_annotations',
);

/// [node] を囲む [ClassDeclaration] を返す.
///
/// Example:
/// ```dart
/// final enclosing = enclosingClassOf(creation);
/// ```
@internal
ClassDeclaration? enclosingClassOf(AstNode node) {
  return node.thisOrAncestorOfType<ClassDeclaration>();
}

/// [type] が指す [InterfaceElement] を返す.
///
/// Example:
/// ```dart
/// final element = interfaceElementOf(expression.staticType);
/// ```
@internal
InterfaceElement? interfaceElementOf(DartType? type) {
  if (type is InterfaceType) {
    return type.element;
  }
  return null;
}

/// [parameter] の解決済み型を返す.
///
/// Example:
/// ```dart
/// final type = resolvedTypeOfParameter(parameter);
/// ```
@internal
DartType? resolvedTypeOfParameter(FormalParameter parameter) {
  return parameter.declaredFragment?.element.type;
}

/// [type] の宣言クラスに [checker] のアノテーションが付いているかを判定する.
///
/// Example:
/// ```dart
/// final isDelegate = typeHasAnnotation(paramType, delegateAnnotationChecker);
/// ```
@internal
bool typeHasAnnotation(DartType? type, TypeChecker checker) {
  final element = interfaceElementOf(type);
  if (element == null) {
    return false;
  }
  return checker.hasAnnotationOf(element, throwOnUnresolved: false);
}
