import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';

/// 名前とパッケージで型／アノテーションを照合する簡易 TypeChecker.
///
/// `custom_lint_builder` の `TypeChecker.fromName` 相当を自前実装する.
@internal
final class TypeChecker {
  /// 照合する型／アノテーション名.
  final String name;

  /// パッケージ名制約（null ならパッケージを問わない）.
  final String? packageName;

  /// [name] と任意の [packageName] でチェッカーを作る.
  ///
  /// Example:
  /// ```dart
  /// const checker = TypeChecker.fromName(
  ///   'Freezed',
  ///   packageName: 'freezed_annotation',
  /// );
  /// ```
  const TypeChecker.fromName(this.name, {this.packageName});

  /// [element] にこの型のアノテーションが付いているかを判定する.
  ///
  /// Example:
  /// ```dart
  /// freezedAnnotationChecker.hasAnnotationOf(classElement);
  /// ```
  bool hasAnnotationOf(
    Element element, {
    bool throwOnUnresolved = true,
  }) {
    for (final annotation in element.metadata.annotations) {
      final value = annotation.computeConstantValue();
      final annotationType = value?.type;
      if (annotationType is InterfaceType &&
          _matchesInterface(annotationType.element)) {
        return true;
      }
      final elementName = annotation.element?.displayName;
      if (elementName == name || elementName == '$name.') {
        return true;
      }
    }
    return false;
  }

  /// [type] がこのチェッカーの型へ代入可能かを判定する.
  ///
  /// Example:
  /// ```dart
  /// if (mutableStateStreamChecker.isAssignableFromType(fieldType)) { ... }
  /// ```
  bool isAssignableFromType(DartType type) {
    if (type is! InterfaceType) {
      return false;
    }
    return _matchesInterface(type.element) ||
        type.allSupertypes.any(
          (superType) => _matchesInterface(superType.element),
        );
  }

  /// [type] がこのチェッカー名と一致するインターフェース型かを判定する.
  ///
  /// スーパータイプの一致は見ず、宣言型そのもののみ照合する.
  ///
  /// Example:
  /// ```dart
  /// stateStreamChecker.isExactlyType(streamType);
  /// ```
  bool isExactlyType(DartType type) {
    if (type is! InterfaceType) {
      return false;
    }
    return _matchesInterface(type.element);
  }

  bool _matchesInterface(InterfaceElement element) {
    if (element.name != name) {
      return false;
    }
    final expectedPackage = packageName;
    if (expectedPackage == null) {
      return true;
    }
    final uri = element.library.uri;
    if (uri.scheme != 'package') {
      return false;
    }
    final segments = uri.pathSegments;
    return segments.isNotEmpty && segments.first == expectedPackage;
  }
}
