import 'dart:io';

import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:flutter_layered_architecture_lint/src/ast_compat.dart';
import 'package:flutter_layered_architecture_lint/src/file_layout/file_layout_checkers.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

final _barrelSnapshotCache = <String, BarrelExportSnapshot>{};

/// [path] と [packageName] からバレル公開面スナップショットを取得する.
///
/// 同一 `lib/` ルートは解析セッション内でキャッシュする.
///
/// Example:
/// ```dart
/// final snapshot = barrelSnapshotForPath(filePath, packageName);
/// ```
@internal
BarrelExportSnapshot? barrelSnapshotForPath(String path, String packageName) {
  if (packageName.isEmpty) {
    return null;
  }
  final libRoot = packageLibRootOf(path);
  if (libRoot == null) {
    return null;
  }
  final key = '$libRoot::$packageName';
  return _barrelSnapshotCache.putIfAbsent(
    key,
    () =>
        collectBarrelExportSnapshot(libRoot: libRoot, packageName: packageName),
  );
}

/// [context] と [path] からパッケージ名を解決する.
///
/// [RuleContext.package] の pubspec を優先し、無ければパスを辿る.
///
/// Example:
/// ```dart
/// final name = packageNameForContext(context, path);
/// ```
@internal
String packageNameForContext(RuleContext context, String path) {
  final package = context.package;
  if (package != null) {
    final fromPubspec = packageNameFromPubspecAt(package.root.path);
    if (fromPubspec != null && fromPubspec.isNotEmpty) {
      return fromPubspec;
    }
  }
  final libRoot = packageLibRootOf(path);
  if (libRoot != null) {
    final packageRoot = p.dirname(p.dirname(libRoot));
    final fromPubspec = packageNameFromPubspecAt(packageRoot);
    if (fromPubspec != null && fromPubspec.isNotEmpty) {
      return fromPubspec;
    }
  }
  return '';
}

/// [packageRoot] の `pubspec.yaml` から `name:` を読む.
///
/// Example:
/// ```dart
/// packageNameFromPubspecAt('/path/to/pkg');
/// ```
@internal
String? packageNameFromPubspecAt(String packageRoot) {
  final pubspec = File(p.join(packageRoot, 'pubspec.yaml'));
  if (!pubspec.existsSync()) {
    return null;
  }
  try {
    for (final line in pubspec.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.startsWith('name:')) {
        return trimmed.substring('name:'.length).trim();
      }
    }
  } on Object {
    return null;
  }
  return null;
}

/// [names] に `show` / `hide` combinator を適用する.
///
/// Example:
/// ```dart
/// applyExportCombinators({'A', 'B'}, combinators);
/// ```
@internal
Set<String> applyExportCombinators(
  Set<String> names,
  NodeList<Combinator> combinators,
) {
  if (combinators.isEmpty) {
    return names;
  }

  var result = Set<String>.of(names);
  for (final combinator in combinators) {
    switch (combinator) {
      case ShowCombinator(:final shownNames):
        final allowed = {for (final id in shownNames) id.name};
        result = result.intersection(allowed);
      case HideCombinator(:final hiddenNames):
        final hidden = {for (final id in hiddenNames) id.name};
        result = result.difference(hidden);
    }
  }
  return result;
}

/// [libRoot] 配下の `library;` 付きバレルから公開名集合を構築する.
///
/// AST の `export` / `show` / `hide` を辿り、session に依存しない.
///
/// Example:
/// ```dart
/// final snapshot = collectBarrelExportSnapshot(
///   libRoot: '/pkg/lib',
///   packageName: 'my_pkg',
/// );
/// ```
@internal
BarrelExportSnapshot collectBarrelExportSnapshot({
  required String libRoot,
  required String packageName,
}) {
  final libDirectory = Directory(libRoot);
  if (!libDirectory.existsSync()) {
    return (hasBarrels: false, exportedNames: <String>{});
  }

  final exportedNames = <String>{};
  var barrelCount = 0;
  final visited = <String>{};

  for (final entity in libDirectory.listSync(followLinks: false)) {
    if (entity is! File) {
      continue;
    }
    final path = entity.path;
    if (!isLibRootDartFile(path)) {
      continue;
    }

    final unit = parseDartFile(path);
    if (unit == null || !hasLibraryDirective(unit)) {
      continue;
    }

    barrelCount += 1;
    exportedNames.addAll(
      collectPublicNamesFromLibraryFile(
        path: path,
        libRoot: libRoot,
        packageName: packageName,
        visited: visited,
      ),
    );
  }

  return (hasBarrels: barrelCount > 0, exportedNames: exportedNames);
}

/// [path] のライブラリが公開するトップレベル名を収集する（export 連鎖対応）.
///
/// Example:
/// ```dart
/// final names = collectPublicNamesFromLibraryFile(
///   path: '/pkg/lib/foo.dart',
///   libRoot: '/pkg/lib',
///   packageName: 'foo',
///   visited: {},
/// );
/// ```
@internal
Set<String> collectPublicNamesFromLibraryFile({
  required String path,
  required String libRoot,
  required String packageName,
  required Set<String> visited,
}) {
  final normalized = p.normalize(path);
  if (!visited.add(normalized)) {
    return {};
  }

  final unit = parseDartFile(normalized);
  if (unit == null) {
    return {};
  }

  final names = <String>{
    for (final symbol in publicTopLevelSymbolsOf(unit)) symbol.name.lexeme,
  };

  for (final directive in unit.directives.whereType<ExportDirective>()) {
    final uri = directive.uri.stringValue;
    if (uri == null) {
      continue;
    }
    final targetPath = resolveExportUri(
      uri: uri,
      fromFilePath: normalized,
      libRoot: libRoot,
      packageName: packageName,
    );
    if (targetPath == null) {
      continue;
    }

    final exported = collectPublicNamesFromLibraryFile(
      path: targetPath,
      libRoot: libRoot,
      packageName: packageName,
      visited: visited,
    );
    names.addAll(applyExportCombinators(exported, directive.combinators));
  }

  return names;
}

/// [unit] に `library` ディレクティブがあるかを判定する.
///
/// Example:
/// ```dart
/// hasLibraryDirective(unit); // true if `library;` present
/// ```
@internal
bool hasLibraryDirective(CompilationUnit unit) {
  return unit.directives.any((directive) => directive is LibraryDirective);
}

/// [name] が [snapshot] のバレル公開名集合に含まれるかを判定する.
///
/// Element 同一性は analyzer Element2 移行で不安定なため、公開名で照合する.
///
/// Example:
/// ```dart
/// if (isExportedNameInBarrels('TodoListScreen', snapshot)) return;
/// ```
@internal
bool isExportedNameInBarrels(String name, BarrelExportSnapshot snapshot) {
  if (name.isEmpty || isPrivateIdentifier(name)) {
    return false;
  }
  return snapshot.exportedNames.contains(name);
}

/// [path] が `lib/` 直下の `.dart` ファイルかを判定する（`lib/src/` は除外）.
///
/// Example:
/// ```dart
/// isLibRootDartFile('/pkg/lib/foo.dart'); // true
/// isLibRootDartFile('/pkg/lib/src/foo.dart'); // false
/// ```
@internal
bool isLibRootDartFile(String path) {
  final libRoot = packageLibRootOf(path);
  if (libRoot == null) {
    return false;
  }
  final normalized = path.replaceAll(r'\', '/');
  if (!normalized.startsWith('$libRoot/')) {
    return false;
  }
  final relative = normalized.substring(libRoot.length + 1);
  return relative.endsWith('.dart') && !relative.contains('/');
}

/// [path] から親へ辿り、`pubspec.yaml` 隣接の `lib/` を返す.
///
/// Example:
/// ```dart
/// packageLibRootByWalkingPubspec('/pkg/test/probe.dart');
/// ```
@internal
String? packageLibRootByWalkingPubspec(String path) {
  var current = path.replaceAll(r'\', '/');
  if (current.endsWith('.dart')) {
    final slash = current.lastIndexOf('/');
    if (slash <= 0) {
      return null;
    }
    current = current.substring(0, slash);
  }

  while (true) {
    if (File('$current/pubspec.yaml').existsSync()) {
      final libRoot = '$current/lib';
      if (Directory(libRoot).existsSync()) {
        return libRoot.replaceAll(r'\', '/');
      }
      return null;
    }
    final slash = current.lastIndexOf('/');
    if (slash <= 0) {
      return null;
    }
    current = current.substring(0, slash);
  }
}

/// [path] が属するパッケージの `lib/` ディレクトリ絶対パスを返す.
///
/// `lib/` を含むパスならそれを優先し、`test/` などでは `pubspec.yaml` を辿る.
///
/// Example:
/// ```dart
/// packageLibRootOf('/pkg/lib/src/foo.dart'); // '/pkg/lib'
/// ```
@internal
String? packageLibRootOf(String path) {
  final normalized = path.replaceAll(r'\', '/');
  final index = normalized.lastIndexOf('/lib/');
  if (index >= 0) {
    return normalized.substring(0, index + '/lib'.length);
  }
  if (normalized.endsWith('/lib')) {
    return normalized;
  }
  return packageLibRootByWalkingPubspec(normalized);
}

/// [path] をパースして CompilationUnit を返す.
///
/// Example:
/// ```dart
/// final unit = parseDartFile('/pkg/lib/foo.dart');
/// ```
@internal
CompilationUnit? parseDartFile(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    return null;
  }
  try {
    return parseString(content: file.readAsStringSync(), path: path).unit;
  } on Object {
    return null;
  }
}

/// [unit] 内の public なトップレベルシンボルを列挙する.
///
/// 対象: class / enum / mixin / 名前付き extension / extension type /
/// トップレベル function（getter/setter 含む） / トップレベル変数・定数 / typedef.
/// `_` 始まりと無名 extension は含めない.
///
/// Example:
/// ```dart
/// final symbols = publicTopLevelSymbolsOf(unit).toList();
/// ```
@internal
Iterable<PublicTopLevelSymbolInfo> publicTopLevelSymbolsOf(
  CompilationUnit unit,
) sync* {
  for (final declaration in unit.declarations) {
    switch (declaration) {
      case ClassDeclaration():
      case EnumDeclaration():
      case MixinDeclaration():
      case ExtensionTypeDeclaration():
      case ExtensionDeclaration():
        final name = typeDeclarationNameToken(declaration);
        if (name != null && !isPrivateIdentifier(name.lexeme)) {
          yield (name: name, node: declaration, annotated: declaration);
        }
      case FunctionDeclaration(:final name):
        if (!isPrivateIdentifier(name.lexeme)) {
          yield (name: name, node: declaration, annotated: declaration);
        }
      case TopLevelVariableDeclaration(:final variables):
        for (final variable in variables.variables) {
          final name = variable.name;
          if (!isPrivateIdentifier(name.lexeme)) {
            yield (name: name, node: variable, annotated: declaration);
          }
        }
      case GenericTypeAlias(:final name):
        if (!isPrivateIdentifier(name.lexeme)) {
          yield (name: name, node: declaration, annotated: declaration);
        }
      case FunctionTypeAlias(:final name):
        if (!isPrivateIdentifier(name.lexeme)) {
          yield (name: name, node: declaration, annotated: declaration);
        }
      default:
        break;
    }
  }
}

/// export URI をファイルパスへ解決する（相対 / 同一 package:）.
///
/// Example:
/// ```dart
/// resolveExportUri(
///   uri: 'src/a.dart',
///   fromFilePath: '/pkg/lib/foo.dart',
///   libRoot: '/pkg/lib',
///   packageName: 'foo',
/// );
/// ```
@internal
String? resolveExportUri({
  required String uri,
  required String fromFilePath,
  required String libRoot,
  required String packageName,
}) {
  if (uri.startsWith('package:')) {
    final withoutScheme = uri.substring('package:'.length);
    final slash = withoutScheme.indexOf('/');
    if (slash < 0) {
      return null;
    }
    final pkg = withoutScheme.substring(0, slash);
    if (pkg != packageName) {
      return null;
    }
    final relative = withoutScheme.substring(slash + 1);
    return p.normalize(p.join(libRoot, relative));
  }

  if (uri.startsWith('dart:')) {
    return null;
  }

  return p.normalize(p.join(p.dirname(fromFilePath), uri));
}

/// バレル公開面のスナップショット.
///
/// `hasBarrels` は `library;` 付きバレルが1つ以上あるか.
/// `exportedNames` は公開 export に現れる名前集合.
@internal
typedef BarrelExportSnapshot = ({
  bool hasBarrels,
  Set<String> exportedNames,
});

/// public トップレベルシンボルの宣言情報.
@internal
typedef PublicTopLevelSymbolInfo = ({
  Token name,
  AstNode node,
  AnnotatedNode annotated,
});
