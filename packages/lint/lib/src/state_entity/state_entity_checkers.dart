import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:flutter_layered_architecture_lint/src/ast_compat.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_type_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/stateful/stateful_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/type_checker.dart';
import 'package:meta/meta.dart';

export 'package:flutter_layered_architecture_lint/src/delegate/delegate_checkers.dart'
    show hasInternalAnnotation;
export 'package:flutter_layered_architecture_lint/src/delegate/delegate_type_checkers.dart'
    show typeHasAnnotation;
export 'package:flutter_layered_architecture_lint/src/stateful/stateful_checkers.dart'
    show freezedAnnotationChecker, isFreezedAnnotatedType;

/// `@State`（annotations package）型チェッカー.
@internal
const stateAnnotationChecker = TypeChecker.fromName(
  'State',
  packageName: 'flutter_layered_architecture_annotations',
);

/// `@Entity` 型チェッカー.
@internal
const entityAnnotationChecker = TypeChecker.fromName(
  'Entity',
  packageName: 'flutter_layered_architecture_annotations',
);

/// ゲート A の検査対象（`@state` / `@entity` いずれか）か.
///
/// Example:
/// ```dart
/// if (!appliesStateEntityGateA(classNode)) {
///   return;
/// }
/// ```
@internal
bool appliesStateEntityGateA(AnnotatedNode node) {
  return hasStateAnnotation(node) || hasEntityAnnotation(node);
}

/// [node] に `@state` / `@State()` が付いているか（AST）.
///
/// Example:
/// ```dart
/// if (!hasStateAnnotation(classNode)) {
///   return;
/// }
/// ```
@internal
bool hasStateAnnotation(AnnotatedNode node) =>
    _hasAnnotationNamed(node, {'state', 'State'});

/// [node] に `@entity` / `@Entity()` が付いているか（AST）.
@internal
bool hasEntityAnnotation(AnnotatedNode node) =>
    _hasAnnotationNamed(node, {'entity', 'Entity'});

/// 同一型への `@state` と `@entity` 同時付与.
@internal
bool hasStateAndEntityAnnotation(AnnotatedNode node) =>
    hasStateAnnotation(node) && hasEntityAnnotation(node);

/// 解決済み型に `@state` が付いているか（ゲート B）.
///
/// NOTE: `parseString` 単体の assert では要素解決できないため **ユニットテスト対象外**。
/// ゲート B は example 正例の `dart analyze` と probe で担保する.
@internal
bool typeHasStateAnnotation(DartType? type) =>
    typeHasAnnotation(type, stateAnnotationChecker);

/// 解決済み型に `@entity` が付いているか（ゲート B）. テスト方針は [typeHasStateAnnotation] と同じ.
@internal
bool typeHasEntityAnnotation(DartType? type) =>
    typeHasAnnotation(type, entityAnnotationChecker);

/// [node] のクラス宣言要素（解決済み）.
///
/// Example:
/// ```dart
/// final element = classElementOf(classNode);
/// ```
@internal
InterfaceElement? classElementOf(ClassDeclaration node) {
  return node.declaredFragment?.element;
}

/// クラス宣言が Freezed 付きか（要素メタデータ）.
///
/// Example:
/// ```dart
/// if (!classHasFreezedAnnotation(classNode)) {
///   reporter.atToken(classDeclarationName(classNode), code);
/// }
/// ```
@internal
bool classHasFreezedAnnotation(ClassDeclaration node) {
  final element = classElementOf(node);
  if (element == null) {
    return false;
  }
  return freezedAnnotationChecker.hasAnnotationOf(
    element,
    throwOnUnresolved: false,
  );
}

/// 主データ factory = `factory` かつコンストラクタ名なし（`name == null`）.
///
/// Example:
/// ```dart
/// final factory = primaryDataFactoryOf(freezedClassNode);
/// ```
@internal
ConstructorDeclaration? primaryDataFactoryOf(ClassDeclaration node) {
  for (final member in classDeclarationMembers(node)) {
    if (member is! ConstructorDeclaration) {
      continue;
    }
    if (member.factoryKeyword != null && member.name == null) {
      return member;
    }
  }
  return null;
}

/// named factory = `factory` かつ `name != null`.
///
/// Example:
/// ```dart
/// for (final named in namedFactoriesOf(classNode)) { ... }
/// ```
@internal
Iterable<ConstructorDeclaration> namedFactoriesOf(ClassDeclaration node) {
  return classDeclarationMembers(node)
      .whereType<ConstructorDeclaration>()
      .where(
        (c) => c.factoryKeyword != null && c.name != null,
      );
}

/// パラメータ metadata に `@Default` があるか.
///
/// Example:
/// ```dart
/// parameterHasDefaultAnnotation(parameter); // @Default(0) int x
/// ```
@internal
bool parameterHasDefaultAnnotation(FormalParameter parameter) {
  for (final metadata in parameter.metadata) {
    final name = metadata.name;
    final simpleName = switch (name) {
      PrefixedIdentifier(:final identifier) => identifier.name,
      SimpleIdentifier(:final name) => name,
    };
    if (simpleName == 'Default') {
      return true;
    }
  }
  return false;
}

/// Dart デフォルト引数（`DefaultFormalParameter` で defaultValue あり、かつ non-required）.
///
/// Example:
/// ```dart
/// parameterHasDartDefaultValue(parameter); // List<int> items = const []
/// ```
@internal
bool parameterHasDartDefaultValue(FormalParameter parameter) {
  return parameter.defaultClause != null && !parameter.isRequired;
}

/// 主データ factory パラメータで `required` でないもの（`required` キーワード欠如）.
///
/// Example:
/// ```dart
/// for (final p in nonRequiredPrimaryFactoryParameters(classNode)) { ... }
/// ```
@internal
Iterable<FormalParameter> nonRequiredPrimaryFactoryParameters(
  ClassDeclaration node,
) sync* {
  final factory = primaryDataFactoryOf(node);
  if (factory == null) {
    return;
  }
  for (final parameter in factory.parameters.parameters) {
    if (!parameter.isRequired) {
      yield parameter;
    }
  }
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
