import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

/// [typeName] に対応する期待ファイル名（`*.dart`）を返す.
///
/// Example:
/// ```dart
/// expectedFileNameForType('AddTodoUsecase'); // 'add_todo_usecase.dart'
/// ```
String expectedFileNameForType(String typeName) {
  return '${pascalToSnakeCase(typeName)}.dart';
}

/// [path] の basename（最後のパス要素）を返す.
///
/// Example:
/// ```dart
/// fileBasename('/pkg/lib/src/add_todo_usecase.dart');
/// // 'add_todo_usecase.dart'
/// ```
String fileBasename(String path) {
  final normalized = path.replaceAll(r'\', '/');
  final parts = normalized.split('/');
  return parts.isEmpty ? normalized : parts.last;
}

/// [unit] が `part of` ファイルかを判定する.
///
/// Example:
/// ```dart
/// hasPartOfDirective(compilationUnit);
/// ```
bool hasPartOfDirective(CompilationUnit unit) {
  return unit.directives.any((directive) => directive is PartOfDirective);
}

/// [name] が private（`_` 始まり）かを判定する.
///
/// Example:
/// ```dart
/// isPrivateIdentifier('_Helper'); // true
/// isPrivateIdentifier('Foo'); // false
/// ```
bool isPrivateIdentifier(String name) => name.startsWith('_');

/// [path] が `test/` ディレクトリ配下かを判定する.
///
/// Example:
/// ```dart
/// isUnderTestDirectory('/pkg/lib/src/foo.dart'); // false
/// isUnderTestDirectory('/pkg/test/foo.dart'); // true
/// ```
bool isUnderTestDirectory(String path) {
  final normalized = path.replaceAll(r'\', '/');
  return normalized.contains('/test/');
}

/// PascalCase の型名を lower_snake_case に変換する.
///
/// Example:
/// ```dart
/// pascalToSnakeCase('AddTodoRequest'); // 'add_todo_request'
/// pascalToSnakeCase('HTTPClient'); // 'http_client'
/// ```
String pascalToSnakeCase(String name) {
  return name
      .replaceAllMapped(
        RegExp('(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])'),
        (_) => '_',
      )
      .toLowerCase();
}

/// [unit] 内の public な名前付き型宣言を列挙する.
///
/// 対象: `class` / `enum` / `mixin` / 名前付き `extension` / `extension type`.
/// `typedef` と `_` 始まり、無名 extension は含めない.
///
/// Example:
/// ```dart
/// final types = publicNamedTypesOf(unit).toList();
/// ```
Iterable<PublicNamedTypeInfo> publicNamedTypesOf(CompilationUnit unit) sync* {
  for (final declaration in unit.declarations) {
    switch (declaration) {
      case ClassDeclaration(:final name):
        if (!isPrivateIdentifier(name.lexeme)) {
          yield (name: name, node: declaration);
        }
      case EnumDeclaration(:final name):
        if (!isPrivateIdentifier(name.lexeme)) {
          yield (name: name, node: declaration);
        }
      case MixinDeclaration(:final name):
        if (!isPrivateIdentifier(name.lexeme)) {
          yield (name: name, node: declaration);
        }
      case ExtensionTypeDeclaration(:final name):
        if (!isPrivateIdentifier(name.lexeme)) {
          yield (name: name, node: declaration);
        }
      case ExtensionDeclaration(:final name?):
        if (!isPrivateIdentifier(name.lexeme)) {
          yield (name: name, node: declaration);
        }
      default:
        break;
    }
  }
}

/// ファイルレイアウト Lint をスキップすべきかを判定する.
///
/// `part of` または `test/` 配下なら true.
///
/// Example:
/// ```dart
/// shouldSkipFileLayoutLint(path: resolver.path, unit: unit);
/// ```
bool shouldSkipFileLayoutLint({
  required String path,
  required CompilationUnit unit,
}) {
  return isUnderTestDirectory(path) || hasPartOfDirective(unit);
}

/// 名前付き public 型の宣言情報（型名トークンとノード）.
typedef PublicNamedTypeInfo = ({Token name, AstNode node});
