import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_layer/architecture_layer_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/ast_compat.dart';
import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart';

/// [typeName] に対応する期待ファイル名（`*.dart`）を返す.
///
/// [keywords] が空なら従来どおり `pascalToSnakeCase` のみ.
///
/// Example:
/// ```dart
/// expectedFileNameForType('AddTodoUsecase'); // 'add_todo_usecase.dart'
/// ```
@internal
String expectedFileNameForType(
  String typeName, {
  List<FileNameKeyword> keywords = const [],
}) {
  final stem = keywords.isEmpty
      ? pascalToSnakeCase(typeName)
      : fileNameStemWithKeywords(typeName, keywords: keywords);
  return '$stem.dart';
}

/// [path] の basename（最後のパス要素）を返す.
///
/// Example:
/// ```dart
/// fileBasename('/pkg/lib/src/add_todo_usecase.dart');
/// // 'add_todo_usecase.dart'
/// ```
@internal
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
@internal
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
@internal
bool isPrivateIdentifier(String name) => name.startsWith('_');

/// [path] が `test/` ディレクトリ配下かを判定する.
///
/// Example:
/// ```dart
/// isUnderTestDirectory('/pkg/lib/src/foo.dart'); // false
/// isUnderTestDirectory('/pkg/test/foo.dart'); // true
/// ```
@internal
bool isUnderTestDirectory(String path) {
  final normalized = path.replaceAll(r'\', '/');
  return normalized.contains('/test/');
}

/// PascalCase 境界（`pascalToSnakeCase` と同一）.
@internal
final RegExp pascalCaseBoundary = RegExp(
  '(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])',
);

/// [name] を PascalCase セグメントに分割する.
///
/// Example:
/// ```dart
/// pascalCaseSegments('AddTodoUseCase'); // ['Add', 'Todo', 'Use', 'Case']
/// pascalCaseSegments('AddTodoUsecase'); // ['Add', 'Todo', 'Usecase']
/// pascalCaseSegments('HTTPClient'); // ['HTTP', 'Client']
/// ```
@internal
List<String> pascalCaseSegments(String name) {
  if (name.isEmpty) {
    return const [];
  }
  return name
      .replaceAllMapped(pascalCaseBoundary, (_) => '\u0000')
      .split('\u0000')
      .where((segment) => segment.isNotEmpty)
      .toList(growable: false);
}

/// 1 キーワード（キーのセグメント列と置換文字列）.
@internal
typedef FileNameKeyword = ({List<String> keySegments, String replacement});

/// [keywords] を記載順・先勝ちで適用し、ファイル名本体（拡張子なし）を返す.
///
/// * 各キーワード処理時、未消費セグメント上を左から走査し、連続一致をすべて置換する
/// * 置換先は **そのまま** 1 ピースとして埋め込む（小文字化しない）
/// * 非置換セグメントは `toLowerCase()` して `_` で結合する
///
/// Example:
/// ```dart
/// fileNameStemWithKeywords(
///   'AddTodoUseCase',
///   keywords: [(keySegments: ['Use', 'Case'], replacement: 'usecase')],
/// ); // 'add_todo_usecase'
/// ```
@internal
String fileNameStemWithKeywords(
  String typeName, {
  required List<FileNameKeyword> keywords,
}) {
  final segments = pascalCaseSegments(typeName);
  if (segments.isEmpty) {
    return typeName.toLowerCase();
  }

  // null = 未消費の生セグメント, non-null = 既に置換済みピース
  final pieces = List<String?>.filled(segments.length, null);

  for (final keyword in keywords) {
    final keySegments = keyword.keySegments;
    if (keySegments.isEmpty) {
      continue;
    }
    var index = 0;
    while (index <= segments.length - keySegments.length) {
      if (pieces[index] != null) {
        index++;
        continue;
      }
      var matches = true;
      for (var offset = 0; offset < keySegments.length; offset++) {
        if (pieces[index + offset] != null ||
            segments[index + offset] != keySegments[offset]) {
          matches = false;
          break;
        }
      }
      if (!matches) {
        index++;
        continue;
      }
      pieces[index] = keyword.replacement;
      for (var offset = 1; offset < keySegments.length; offset++) {
        pieces[index + offset] = ''; // 消費済みマーカー（結合時スキップ）
      }
      index += keySegments.length;
    }
  }

  final out = <String>[];
  for (var index = 0; index < segments.length; index++) {
    final piece = pieces[index];
    if (piece == null) {
      out.add(segments[index].toLowerCase());
    } else if (piece.isNotEmpty) {
      out.add(piece);
    }
  }
  return out.join('_');
}

/// PascalCase の型名を lower_snake_case に変換する.
///
/// Example:
/// ```dart
/// pascalToSnakeCase('AddTodoRequest'); // 'add_todo_request'
/// pascalToSnakeCase('HTTPClient'); // 'http_client'
/// ```
@internal
String pascalToSnakeCase(String name) {
  return name.replaceAllMapped(pascalCaseBoundary, (_) => '_').toLowerCase();
}

/// yaml 全文から `rules.public_type_file_name.keywords` を記載順で読む.
///
/// * 不正・欠落は空リスト（WARNING なし）
/// * スキップ条件: キーが非 String / 空 / セグメント空、値が非 String / 空
///
/// Example:
/// ```dart
/// parsePublicTypeFileNameKeywords(yamlText);
/// ```
@internal
List<FileNameKeyword> parsePublicTypeFileNameKeywords(String yamlText) {
  final Object? document;
  try {
    document = loadYaml(yamlText);
  } on YamlException {
    return const [];
  }
  if (document is! YamlMap) {
    return const [];
  }
  final rules = document['rules'];
  if (rules is! YamlMap) {
    return const [];
  }
  final ruleConfig = rules['public_type_file_name'];
  if (ruleConfig is! YamlMap) {
    return const [];
  }
  final keywordsNode = ruleConfig['keywords'];
  if (keywordsNode is! YamlMap) {
    return const [];
  }

  final result = <FileNameKeyword>[];
  for (final entry in keywordsNode.entries) {
    final key = entry.key;
    final value = entry.value;
    if (key is! String || key.isEmpty) {
      continue;
    }
    if (value is! String || value.isEmpty) {
      continue;
    }
    final keySegments = pascalCaseSegments(key);
    if (keySegments.isEmpty) {
      continue;
    }
    result.add((keySegments: keySegments, replacement: value));
  }
  return result;
}

/// 解析対象ファイルパスからキーワード設定を解決する（無ければ空）.
///
/// Example:
/// ```dart
/// resolveFileNameKeywordsForPath('/pkg/lib/add_todo_usecase.dart');
/// ```
@internal
List<FileNameKeyword> resolveFileNameKeywordsForPath(String filePath) {
  final packageRoot = findPackageRoot(filePath);
  if (packageRoot == null) {
    return const [];
  }
  final yamlPath = findLayeredArchitectureYaml(packageRoot);
  if (yamlPath == null) {
    return const [];
  }
  final text = readTextFile(yamlPath);
  if (text == null) {
    return const [];
  }
  return parsePublicTypeFileNameKeywords(text);
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
@internal
Iterable<PublicNamedTypeInfo> publicNamedTypesOf(CompilationUnit unit) sync* {
  for (final declaration in unit.declarations) {
    final name = typeDeclarationNameToken(declaration);
    if (name == null || isPrivateIdentifier(name.lexeme)) {
      continue;
    }
    switch (declaration) {
      case ClassDeclaration():
      case EnumDeclaration():
      case MixinDeclaration():
      case ExtensionTypeDeclaration():
      case ExtensionDeclaration():
        yield (name: name, node: declaration);
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
@internal
bool shouldSkipFileLayoutLint({
  required String path,
  required CompilationUnit unit,
}) {
  return isUnderTestDirectory(path) || hasPartOfDirective(unit);
}

/// 名前付き public 型の宣言情報（型名トークンとノード）.
@internal
typedef PublicNamedTypeInfo = ({Token name, AstNode node});
