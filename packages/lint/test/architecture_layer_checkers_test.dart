import 'dart:io';

import 'package:flutter_layered_architecture_lint/src/architecture_layer/architecture_layer_checkers.dart';
import 'package:path/path.dart' as p;

/// `package:test` は workspace の flutter_test / analyzer ^8 と解決不能なため、
/// assert ベースのランナーで unit test 相当を実行する.
///
/// 実行: `dart run test/architecture_layer_checkers_test.dart`
void main() {
  group('normalizePathForCompare / isPathUnderPrefix', () {
    test('normalizes Windows separators', () {
      expectEquals(
        normalizePathForCompare(r'C:\ws\example\data'),
        'C:/ws/example/data',
      );
    });

    test('data is under data prefix but database is not', () {
      expectTrue(
        isPathUnderPrefix(
          path: '/ws/example/data/repo',
          prefix: '/ws/example/data',
        ),
      );
      expectFalse(
        isPathUnderPrefix(
          path: '/ws/example/database',
          prefix: '/ws/example/data',
        ),
      );
    });
  });

  group('resolvePathPrefix', () {
    test('joins definition directory and prefix', () {
      expectEquals(
        resolvePathPrefix(definitionDir: '/ws', pathPrefix: 'example/data'),
        '/ws/example/data',
      );
    });
  });

  group('findPackageRoot', () {
    test('finds root from lib file path', () {
      final tempDir = Directory.systemTemp.createTempSync('arch_layer_root_');
      try {
        final packageRoot = p.join(tempDir.path, 'my_pkg');
        Directory(p.join(packageRoot, 'lib')).createSync(recursive: true);
        File(p.join(packageRoot, 'pubspec.yaml'))
            .writeAsStringSync('name: my_pkg\n');
        final dartFile = p.join(packageRoot, 'lib', 'foo.dart');
        File(dartFile).writeAsStringSync('void main() {}');
        expectEquals(
          findPackageRoot(dartFile),
          normalizePathForCompare(packageRoot),
        );
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });

  group('findPackageConfigJson', () {
    test('finds ancestor workspace package_config.json', () {
      final tempDir = Directory.systemTemp.createTempSync('arch_pkg_cfg_');
      try {
        final workspaceRoot = p.join(tempDir.path, 'ws');
        final packagePath = p.join(workspaceRoot, 'example', 'usecase', 'todo');
        Directory(packagePath).createSync(recursive: true);
        final dartTool = p.join(workspaceRoot, '.dart_tool');
        Directory(dartTool).createSync(recursive: true);
        final configPath = p.join(dartTool, 'package_config.json');
        File(configPath).writeAsStringSync('{"configVersion":2,"packages":[]}');
        expectEquals(
          findPackageConfigJson(packagePath),
          normalizePathForCompare(configPath),
        );
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });

  group('findLayeredArchitectureYaml', () {
    test('prefers nearest parent yaml', () {
      final tempDir = Directory.systemTemp.createTempSync('arch_layer_yaml_');
      try {
        final root = p.join(tempDir.path, 'ws');
        final parentYaml = p.join(root, 'layered_architecture.yaml');
        final childDir = p.join(root, 'child');
        Directory(childDir).createSync(recursive: true);
        final childYaml = p.join(childDir, 'layered_architecture.yaml');
        File(parentYaml).writeAsStringSync('layers: []\n');
        File(childYaml).writeAsStringSync('layers: []\n');
        expectEquals(
          findLayeredArchitectureYaml(childDir),
          normalizePathForCompare(childYaml),
        );
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });

  group('findPathPrefixOverlaps', () {
    test('detects duplicate and contains', () {
      const definitionDir = '/ws';
      final duplicateLayers = [
        const ArchitectureLayer(
          name: 'a',
          level: 1,
          pathPrefix: 'example/data',
        ),
        const ArchitectureLayer(
          name: 'b',
          level: 2,
          pathPrefix: 'example/data',
        ),
      ];
      final duplicates = findPathPrefixOverlaps(
        definitionDir: definitionDir,
        layers: duplicateLayers,
      );
      expectEquals(duplicates.length, 1);
      expectEquals(duplicates.single.reason, 'duplicate');

      final containsLayers = [
        const ArchitectureLayer(
          name: 'data',
          level: 4,
          pathPrefix: 'example/data',
        ),
        const ArchitectureLayer(
          name: 'data_child',
          level: 3,
          pathPrefix: 'example/data/repo',
        ),
      ];
      final contains = findPathPrefixOverlaps(
        definitionDir: definitionDir,
        layers: containsLayers,
      );
      expectEquals(contains.length, 1);
      expectEquals(contains.single.reason, 'contains');

      final distinctLayers = [
        const ArchitectureLayer(
          name: 'data',
          level: 4,
          pathPrefix: 'example/data',
        ),
        const ArchitectureLayer(
          name: 'domain',
          level: 2,
          pathPrefix: 'example/domain',
        ),
      ];
      expectEquals(
        findPathPrefixOverlaps(
          definitionDir: definitionDir,
          layers: distinctLayers,
        ).length,
        0,
      );
    });
  });

  group('parseLayerArchitectureYaml', () {
    test('parses valid definition', () {
      final result = parseLayerArchitectureYaml('''
layers:
  - data:
      level: 4
      path_prefix: example/data
''');
      expectTrue(result is LayerArchitectureDefinition);
      final definition = result as LayerArchitectureDefinition;
      expectEquals(definition.layers.length, 1);
      expectEquals(definition.layers.single.name, 'data');
      expectEquals(definition.layers.single.level, 4);
      expectEquals(definition.layers.single.pathPrefix, 'example/data');
    });

    test('fails when path_prefix missing', () {
      final result = parseLayerArchitectureYaml('''
layers:
  - data:
      level: 4
''');
      expectTrue(result is LayerArchitectureParseFailure);
    });

    test('fails on invalid YAML', () {
      final result = parseLayerArchitectureYaml('layers: [');
      expectTrue(result is LayerArchitectureParseFailure);
    });

    test('fails when level is zero', () {
      final result = parseLayerArchitectureYaml('''
layers:
  - data:
      level: 0
      path_prefix: example/data
''');
      expectTrue(result is LayerArchitectureParseFailure);
    });

    test('fails when level is negative', () {
      final result = parseLayerArchitectureYaml('''
layers:
  - data:
      level: -1
      path_prefix: example/data
''');
      expectTrue(result is LayerArchitectureParseFailure);
    });
  });

  group('isLevelViolation / hasAnyLevelViolation', () {
    test('detects upward dependency', () {
      const domain = ArchitectureLayer(
        name: 'domain',
        level: 2,
        pathPrefix: 'example/domain',
      );
      const usecase = ArchitectureLayer(
        name: 'usecase',
        level: 4,
        pathPrefix: 'example/usecase',
      );
      expectTrue(isLevelViolation(selfLayer: domain, dependencyLayer: usecase));
      expectTrue(
        hasAnyLevelViolation(
          selfLayers: [domain],
          dependencyLayers: [usecase],
        ),
      );
      expectFalse(
        hasAnyLevelViolation(
          selfLayers: [usecase],
          dependencyLayers: [domain],
        ),
      );
    });
  });

  group('parseDirectDependencyNames', () {
    test('extracts dependency package names', () {
      final parsed = parseDirectDependencyNames('''
name: usecase_todo
dependencies:
  domain_todo: any
dev_dependencies:
  lints: ^6.0.0
''');
      expectEquals(parsed.dependencies.length, 1);
      expectEquals(parsed.dependencies.single, 'domain_todo');
      expectEquals(parsed.devDependencies.length, 1);
      expectEquals(parsed.devDependencies.single, 'lints');
    });
  });

  group('packageRootsFromPackageConfig', () {
    test('resolves package root paths', () {
      final tempDir = Directory.systemTemp.createTempSync('arch_pkg_roots_');
      try {
        final dartTool = p.join(tempDir.path, '.dart_tool');
        Directory(dartTool).createSync(recursive: true);
        final packageRoot = p.join(tempDir.path, 'example', 'domain', 'todo');
        Directory(packageRoot).createSync(recursive: true);
        const json = '''
{
  "configVersion": 2,
  "packages": [
    {
      "name": "domain_todo",
      "rootUri": "../example/domain/todo",
      "packageUri": "lib/",
      "languageVersion": "3.14"
    }
  ]
}
''';
        final roots = packageRootsFromPackageConfig(
          packageConfigJsonText: json,
          packageConfigFileDirectory: dartTool,
        );
        expectEquals(
          roots['domain_todo'],
          normalizePathForCompare(packageRoot),
        );
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });

  group('layersForPackagePath', () {
    test('matches nested impl package to parent layer', () {
      const definitionDir = '/ws';
      const layers = [
        ArchitectureLayer(
          name: 'usecase',
          level: 4,
          pathPrefix: 'example/usecase',
        ),
        ArchitectureLayer(name: 'data', level: 2, pathPrefix: 'example/data'),
      ];
      final matched = layersForPackagePath(
        definitionDir: definitionDir,
        layers: layers,
        packageRootPath: '/ws/example/usecase/todo/_impl',
      );
      expectEquals(matched.length, 1);
      expectEquals(matched.single.name, 'usecase');
    });

    test('overlapping path_prefix yields multiple layer matches', () {
      const definitionDir = '/ws';
      const layers = [
        ArchitectureLayer(
          name: 'data',
          level: 4,
          pathPrefix: 'example/data',
        ),
        ArchitectureLayer(
          name: 'data_repository',
          level: 4,
          pathPrefix: 'example/data/repository',
        ),
      ];
      final matched = layersForPackagePath(
        definitionDir: definitionDir,
        layers: layers,
        packageRootPath: '/ws/example/data/repository/todo',
      );
      // 複数マッチは許可しない。呼び出し側で warning し依存検査を止める前提.
      expectEquals(matched.length, 2);
    });
  });

  // ignore: avoid_print
  print('All architecture_layer_checkers tests passed.');
}

void expectEquals(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected: <$expected>\n  Actual: <$actual>');
  }
}

void expectFalse(bool actual) {
  if (actual) {
    throw Exception('Expected: <false>\n  Actual: <$actual>');
  }
}

void expectTrue(bool actual) {
  if (!actual) {
    throw Exception('Expected: <true>\n  Actual: <$actual>');
  }
}

void group(String name, void Function() body) {
  body();
}

void test(String name, void Function() body) {
  try {
    body();
  } on Exception catch (error, stackTrace) {
    // ignore: avoid_print
    print('FAILED: $name');
    // ignore: avoid_print
    print(error);
    // ignore: avoid_print
    print(stackTrace);
    throw Exception('Test failed: $name');
  }
}
