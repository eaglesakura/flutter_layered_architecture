// checker 用の複数 @internal モデル型を同一ファイルにまとめる（Visitor 非依存 API 正本）.
// ignore_for_file: flutter_layered_architecture_lint/one_public_type_per_file

import 'dart:io';

import 'package:meta/meta.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// `layered_architecture.yaml` の正本名.
@internal
const layeredArchitectureFileName = 'layered_architecture.yaml';

/// `findUpwardsFile(startDirectory, layeredArchitectureFileName)`.
///
/// Example:
/// ```dart
/// // /ws/example/usecase から /ws/layered_architecture.yaml を発見
/// findLayeredArchitectureYaml('/ws/example/usecase');
/// ```
@internal
String? findLayeredArchitectureYaml(String startDirectory) {
  return findUpwardsFile(startDirectory, layeredArchitectureFileName);
}

/// [startDir] の各祖先について `{dir}/.dart_tool/package_config.json` の存在を試し、
/// 最初に見つかった絶対パスを返す（workspace ルートの package_config 向け）.
///
/// Example:
/// ```dart
/// findPackageConfigJson('/ws/example/usecase/todo');
/// // '/ws/.dart_tool/package_config.json'
/// ```
@internal
String? findPackageConfigJson(String startDir) {
  var directory = p.normalize(startDir);
  while (true) {
    final candidate = p.join(directory, '.dart_tool', 'package_config.json');
    if (File(candidate).existsSync()) {
      return normalizePathForCompare(p.normalize(candidate));
    }
    final parent = p.normalize(p.dirname(directory));
    if (parent == directory) {
      return null;
    }
    directory = parent;
  }
}

/// [startPath]（ファイルまたはディレクトリ）から親へ辿り、`pubspec.yaml` があるディレクトリを返す.
///
/// Example:
/// ```dart
/// findPackageRoot('/ws/example/usecase/todo/lib/src/x.dart');
/// // '/ws/example/usecase/todo'
/// ```
@internal
String? findPackageRoot(String startPath) {
  var directory = FileSystemEntity.isDirectorySync(startPath)
      ? startPath
      : p.dirname(startPath);
  directory = p.normalize(directory);
  while (true) {
    final pubspecPath = p.join(directory, 'pubspec.yaml');
    if (File(pubspecPath).existsSync()) {
      return normalizePathForCompare(directory);
    }
    final parent = p.normalize(p.dirname(directory));
    if (parent == directory) {
      return null;
    }
    directory = parent;
  }
}

/// duplicate / contains を返す. 無ければ空.
///
/// Example:
/// ```dart
/// findPathPrefixOverlaps(definitionDir: '/ws', layers: [data, dataChild]);
/// // reason == 'contains'
/// ```
@internal
List<PathPrefixOverlap> findPathPrefixOverlaps({
  required String definitionDir,
  required List<ArchitectureLayer> layers,
}) {
  final overlaps = <PathPrefixOverlap>[];
  final resolved = [
    for (final layer in layers)
      (
        layer: layer,
        path: resolvePathPrefix(
          definitionDir: definitionDir,
          pathPrefix: layer.pathPrefix,
        ),
      ),
  ];

  for (var indexA = 0; indexA < resolved.length; indexA++) {
    for (var indexB = indexA + 1; indexB < resolved.length; indexB++) {
      final entryA = resolved[indexA];
      final entryB = resolved[indexB];
      if (entryA.path == entryB.path) {
        overlaps.add(
          PathPrefixOverlap(
            layerA: entryA.layer.name,
            layerB: entryB.layer.name,
            reason: 'duplicate',
          ),
        );
        continue;
      }
      if (isPathUnderPrefix(path: entryB.path, prefix: entryA.path)) {
        overlaps.add(
          PathPrefixOverlap(
            layerA: entryA.layer.name,
            layerB: entryB.layer.name,
            reason: 'contains',
          ),
        );
      } else if (isPathUnderPrefix(path: entryA.path, prefix: entryB.path)) {
        overlaps.add(
          PathPrefixOverlap(
            layerA: entryB.layer.name,
            layerB: entryA.layer.name,
            reason: 'contains',
          ),
        );
      }
    }
  }
  return overlaps;
}

/// [startDir] から親へ辿り、最初に見つかった [fileName] の絶対パスを返す.
///
/// Example:
/// ```dart
/// findUpwardsFile('/ws/example/usecase', 'layered_architecture.yaml');
/// // '/ws/layered_architecture.yaml'
/// ```
@internal
String? findUpwardsFile(String startDir, String fileName) {
  var directory = p.normalize(startDir);
  while (true) {
    final candidate = p.join(directory, fileName);
    if (File(candidate).existsSync()) {
      return normalizePathForCompare(p.normalize(candidate));
    }
    final parent = p.normalize(p.dirname(directory));
    if (parent == directory) {
      return null;
    }
    directory = parent;
  }
}

/// 自己 × 依存の各レイヤー組み合わせで、いずれか 1 つでも level 違反なら true.
///
/// 本番 Visitor は所属を単一に正規化したうえで [isLevelViolation] を使う。
/// 本関数は単体テスト用の組み合わせ検査ヘルパーとして残す.
///
/// Example:
/// ```dart
/// hasAnyLevelViolation(selfLayers: [domain], dependencyLayers: [usecase]); // true
/// ```
@internal
bool hasAnyLevelViolation({
  required List<ArchitectureLayer> selfLayers,
  required List<ArchitectureLayer> dependencyLayers,
}) {
  for (final selfLayer in selfLayers) {
    for (final dependencyLayer in dependencyLayers) {
      if (isLevelViolation(
        selfLayer: selfLayer,
        dependencyLayer: dependencyLayer,
      )) {
        return true;
      }
    }
  }
  return false;
}

/// 双方 level ありかつ dep.level > self.level のとき true.
///
/// Example:
/// ```dart
/// isLevelViolation(selfLayer: domainL2, dependencyLayer: usecaseL4); // true
/// ```
@internal
bool isLevelViolation({
  required ArchitectureLayer selfLayer,
  required ArchitectureLayer dependencyLayer,
}) {
  final selfLevel = selfLayer.level;
  final dependencyLevel = dependencyLayer.level;
  if (selfLevel == null || dependencyLevel == null) {
    return false;
  }
  return dependencyLevel > selfLevel;
}

/// [path] が [prefix] 配下（または同一）か. 区切り境界を尊重する.
///
/// Example:
/// ```dart
/// isPathUnderPrefix(path: '/ws/example/data/repo', prefix: '/ws/example/data'); // true
/// isPathUnderPrefix(path: '/ws/example/database', prefix: '/ws/example/data'); // false
/// ```
@internal
bool isPathUnderPrefix({required String path, required String prefix}) {
  final normalizedPath = normalizePathForCompare(path);
  final normalizedPrefix = normalizePathForCompare(prefix);
  if (normalizedPath == normalizedPrefix) {
    return true;
  }
  return normalizedPath.startsWith('$normalizedPrefix/');
}

/// package root がマッチするレイヤーをすべて返す.
///
/// 通常は 0 または 1 件。2 件以上は `path_prefix` 重複・包括であり **許可しない**。
/// 呼び出し側は length > 1 を warning とし、依存方向検査を行わないこと.
///
/// Example:
/// ```dart
/// layersForPackagePath(..., packageRootPath: '/ws/example/usecase/todo/_impl');
/// // usecase layer
/// ```
@internal
List<ArchitectureLayer> layersForPackagePath({
  required String definitionDir,
  required List<ArchitectureLayer> layers,
  required String packageRootPath,
}) {
  final normalizedPackageRoot = normalizePathForCompare(
    p.normalize(packageRootPath),
  );
  final matched = <ArchitectureLayer>[];
  for (final layer in layers) {
    final prefix = resolvePathPrefix(
      definitionDir: definitionDir,
      pathPrefix: layer.pathPrefix,
    );
    if (isPathUnderPrefix(path: normalizedPackageRoot, prefix: prefix)) {
      matched.add(layer);
    }
  }
  return matched;
}

/// パスを `/` 区切りへ正規化する.
///
/// Example:
/// ```dart
/// normalizePathForCompare(r'C:\a\b'); // 'C:/a/b'
/// ```
@internal
String normalizePathForCompare(String path) {
  return p.normalize(path).replaceAll(r'\', '/');
}

/// `PackageConfig.parseString` で読み、各 package の rootUri を
/// [packageConfigFileDirectory] 基準で絶対正規化パスへ変換した map を返す.
/// パース失敗は空 map.
///
/// Example:
/// ```dart
/// packageRootsFromPackageConfig(
///   packageConfigJsonText: json,
///   packageConfigFileDirectory: '/ws/.dart_tool',
/// );
/// ```
@internal
Map<String, String> packageRootsFromPackageConfig({
  required String packageConfigJsonText,
  required String packageConfigFileDirectory,
}) {
  try {
    final baseUri = Uri.directory(p.normalize(packageConfigFileDirectory));
    final configuration = PackageConfig.parseString(
      packageConfigJsonText,
      baseUri,
    );
    final roots = <String, String>{};
    for (final package in configuration.packages) {
      final rootUri = package.root;
      if (rootUri.scheme != 'file') {
        continue;
      }
      roots[package.name] = normalizePathForCompare(
        p.normalize(rootUri.toFilePath()),
      );
    }
    return roots;
  } on Object {
    return {};
  }
}

/// `dependencies` / `dev_dependencies` の直接依存パッケージ名を抽出する.
///
/// Example:
/// ```dart
/// parseDirectDependencyNames('dependencies:\n  domain_todo: any\n');
/// // dependencies == ['domain_todo']
/// ```
@internal
DirectDependencies parseDirectDependencyNames(String pubspecYamlText) {
  final Object? document;
  try {
    document = loadYaml(pubspecYamlText);
  } on YamlException {
    return DirectDependencies(
      dependencies: const [],
      devDependencies: const [],
    );
  }

  if (document is! YamlMap) {
    return DirectDependencies(
      dependencies: const [],
      devDependencies: const [],
    );
  }

  return DirectDependencies(
    dependencies: _dependencyNames(document['dependencies']),
    devDependencies: _dependencyNames(document['dev_dependencies']),
  );
}

/// layers list / 単一キー map / path_prefix 必須非空.
/// level 指定時は int かつ > 0。0・負・非 int は ParseFailure.
///
/// Example:
/// ```dart
/// parseLayerArchitectureYaml('layers:\n  - data:\n      level: 4\n      path_prefix: example/data');
/// ```
@internal
LayerArchitectureParseResult parseLayerArchitectureYaml(String yamlText) {
  final Object? document;
  try {
    document = loadYaml(yamlText);
  } on YamlException catch (error) {
    return LayerArchitectureParseFailure('Invalid YAML: ${error.message}');
  }

  if (document is! YamlMap) {
    return LayerArchitectureParseFailure('Top-level YAML must be a map');
  }

  final layersNode = document['layers'];
  if (layersNode is! YamlList) {
    return LayerArchitectureParseFailure('layers must be a list');
  }

  final layers = <ArchitectureLayer>[];
  for (final layerEntry in layersNode) {
    if (layerEntry is! YamlMap) {
      return LayerArchitectureParseFailure('Each layers entry must be a map');
    }
    if (layerEntry.length != 1) {
      return LayerArchitectureParseFailure(
        'Each layers entry must be a single-key map',
      );
    }

    final layerName = layerEntry.keys.single.toString();
    final layerConfig = layerEntry.values.single;
    if (layerConfig is! YamlMap) {
      return LayerArchitectureParseFailure(
        'Layer "$layerName" must be configured as a map',
      );
    }

    final pathPrefix = layerConfig['path_prefix'];
    if (pathPrefix is! String || pathPrefix.isEmpty) {
      return LayerArchitectureParseFailure(
        'path_prefix is required for layer "$layerName"',
      );
    }

    int? level;
    if (layerConfig.keys.contains('level')) {
      final levelValue = layerConfig['level'];
      if (levelValue is! int) {
        return LayerArchitectureParseFailure(
          'level must be a positive integer for layer "$layerName"',
        );
      }
      if (levelValue <= 0) {
        return LayerArchitectureParseFailure(
          'level must be a positive integer for layer "$layerName"',
        );
      }
      level = levelValue;
    }

    layers.add(
      ArchitectureLayer(name: layerName, level: level, pathPrefix: pathPrefix),
    );
  }

  return LayerArchitectureDefinition(layers);
}

/// 同期でテキストを読む. 失敗時 null（`dart:io` File.readAsStringSync）.
/// Analyzer プラグインでは同期 I/O を用いる（`avoid_slow_async_io` は非同期 File 向け）.
///
/// Example:
/// ```dart
/// readTextFile('/ws/layered_architecture.yaml'); // yaml text or null
/// ```
@internal
String? readTextFile(String path) {
  try {
    return File(path).readAsStringSync();
  } on FileSystemException {
    return null;
  } on IOException {
    return null;
  }
}

/// 定義ディレクトリ + 相対 path_prefix → 絶対正規化パス.
///
/// Example:
/// ```dart
/// resolvePathPrefix(definitionDir: '/ws', pathPrefix: 'example/data');
/// // '/ws/example/data'
/// ```
@internal
String resolvePathPrefix({
  required String definitionDir,
  required String pathPrefix,
}) {
  return normalizePathForCompare(p.join(definitionDir, pathPrefix));
}

List<String> _dependencyNames(Object? section) {
  if (section is! YamlMap) {
    return const [];
  }
  return [
    for (final key in section.keys)
      if (key is String) key,
  ];
}

@internal
final class ArchitectureLayer {
  final String name;

  final int? level;
  final String pathPrefix;
  const ArchitectureLayer({
    required this.name,
    required this.level,
    required this.pathPrefix,
  });
}

@internal
final class DirectDependencies {
  final List<String> dependencies;

  final List<String> devDependencies;
  DirectDependencies({
    required this.dependencies,
    required this.devDependencies,
  });
}

@internal
final class LayerArchitectureDefinition extends LayerArchitectureParseResult {
  final List<ArchitectureLayer> layers;

  LayerArchitectureDefinition(this.layers);
}

@internal
final class LayerArchitectureParseFailure extends LayerArchitectureParseResult {
  final String message;

  LayerArchitectureParseFailure(this.message);
}

@internal
sealed class LayerArchitectureParseResult {}

/// ignore パース成功. [entries] は記載順（trim しない。重複はそのまま）.
@internal
final class ArchitectureLayerIgnoreParseSuccess
    extends ArchitectureLayerIgnoreParseResult {
  final List<String> entries;

  ArchitectureLayerIgnoreParseSuccess(this.entries);
}

/// ignore 形式不正.
@internal
final class ArchitectureLayerIgnoreParseFailure
    extends ArchitectureLayerIgnoreParseResult {
  final String message;

  ArchitectureLayerIgnoreParseFailure(this.message);
}

@internal
sealed class ArchitectureLayerIgnoreParseResult {}

/// yaml 全文から `rules.architecture_layer_dependency.ignore` を読む.
///
/// * 辿り方は keywords に倣うが、不正時は空成功にせず Failure.
/// * 要素不正はスキップせず全体 Failure（以降の要素は見ない）.
/// * 文字列は trim しない.
///
/// Example:
/// ```dart
/// parseArchitectureLayerDependencyIgnore('rules:\n  architecture_layer_dependency:\n    ignore:\n      - a\n');
/// ```
@internal
ArchitectureLayerIgnoreParseResult parseArchitectureLayerDependencyIgnore(
  String yamlText,
) {
  final Object? document;
  try {
    document = loadYaml(yamlText);
  } on YamlException catch (error) {
    return ArchitectureLayerIgnoreParseFailure(
      'Invalid YAML: ${error.message}',
    );
  }
  if (document is! YamlMap) {
    return ArchitectureLayerIgnoreParseFailure('Top-level YAML must be a map');
  }

  final rules = document['rules'];
  if (rules == null) {
    return ArchitectureLayerIgnoreParseSuccess(const []);
  }
  if (rules is! YamlMap) {
    return ArchitectureLayerIgnoreParseFailure('rules must be a map');
  }

  final ruleConfig = rules['architecture_layer_dependency'];
  if (ruleConfig == null) {
    return ArchitectureLayerIgnoreParseSuccess(const []);
  }
  if (ruleConfig is! YamlMap) {
    return ArchitectureLayerIgnoreParseFailure(
      'rules.architecture_layer_dependency must be a map',
    );
  }

  if (!ruleConfig.keys.contains('ignore')) {
    return ArchitectureLayerIgnoreParseSuccess(const []);
  }

  final ignoreNode = ruleConfig['ignore'];
  if (ignoreNode == null) {
    return ArchitectureLayerIgnoreParseSuccess(const []);
  }
  if (ignoreNode is! YamlList) {
    return ArchitectureLayerIgnoreParseFailure(
      'rules.architecture_layer_dependency.ignore must be a list',
    );
  }

  final entries = <String>[];
  for (final item in ignoreNode) {
    if (item is! String) {
      return ArchitectureLayerIgnoreParseFailure(
        'ignore entries must be non-empty strings',
      );
    }
    if (item.isEmpty) {
      return ArchitectureLayerIgnoreParseFailure(
        'ignore entries must be non-empty strings',
      );
    }
    entries.add(item);
  }
  return ArchitectureLayerIgnoreParseSuccess(entries);
}

/// pubspec yaml 全文から `name` を取る. 非 String・空・欠落は null. trim しない.
///
/// Example:
/// ```dart
/// parsePackageNameFromPubspecYaml('name: foo\n'); // 'foo'
/// ```
@internal
String? parsePackageNameFromPubspecYaml(String pubspecYamlText) {
  final Object? document;
  try {
    document = loadYaml(pubspecYamlText);
  } on YamlException {
    return null;
  }
  if (document is! YamlMap) {
    return null;
  }
  final name = document['name'];
  if (name is! String || name.isEmpty) {
    return null;
  }
  return name;
}

/// ignore 名のうち [packageRoots] に無いものを記載順で返す.
@internal
List<String> unresolvedIgnorePackageNames({
  required List<String> ignoreNames,
  required Map<String, String> packageRoots,
}) {
  return [
    for (final name in ignoreNames)
      if (!packageRoots.containsKey(name)) name,
  ];
}

/// ignore が有効かつ self 名が entries に完全一致するとき true.
@internal
bool shouldSkipDependencyDirectionForPackage({
  required bool ignoreConfigValid,
  required List<String> ignoreEntries,
  required String? selfPackageName,
}) {
  if (!ignoreConfigValid) {
    return false;
  }
  if (selfPackageName == null || selfPackageName.isEmpty) {
    return false;
  }
  return ignoreEntries.contains(selfPackageName);
}

@internal
final class PathPrefixOverlap {
  final String layerA;

  final String layerB;

  /// `duplicate` または `contains`.
  final String reason;

  PathPrefixOverlap({
    required this.layerA,
    required this.layerB,
    required this.reason,
  });
}
