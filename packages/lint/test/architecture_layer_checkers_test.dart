import 'dart:io';

import 'package:flutter_layered_architecture_lint/src/architecture_layer/architecture_layer_checkers.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('normalizePathForCompare / isPathUnderPrefix', () {
    test('normalizes Windows separators', () {
      expect(
        normalizePathForCompare(r'C:\ws\example\data'),
        'C:/ws/example/data',
      );
    });

    test('data is under data prefix but database is not', () {
      expect(
        isPathUnderPrefix(
          path: '/ws/example/data/repo',
          prefix: '/ws/example/data',
        ),
        isTrue,
      );
      expect(
        isPathUnderPrefix(
          path: '/ws/example/database',
          prefix: '/ws/example/data',
        ),
        isFalse,
      );
    });
  });

  group('resolvePathPrefix', () {
    test('joins definition directory and prefix', () {
      expect(
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
        File(
          p.join(packageRoot, 'pubspec.yaml'),
        ).writeAsStringSync('name: my_pkg\n');
        final dartFile = p.join(packageRoot, 'lib', 'foo.dart');
        File(dartFile).writeAsStringSync('void main() {}');
        expect(
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
        expect(
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
        expect(
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
      expect(duplicates.length, 1);
      expect(duplicates.single.reason, 'duplicate');

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
      expect(contains.length, 1);
      expect(contains.single.reason, 'contains');

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
      expect(
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
      expect(result is LayerArchitectureDefinition, isTrue);
      final definition = result as LayerArchitectureDefinition;
      expect(definition.layers.length, 1);
      expect(definition.layers.single.name, 'data');
      expect(definition.layers.single.level, 4);
      expect(definition.layers.single.pathPrefix, 'example/data');
    });

    test('fails when path_prefix missing', () {
      final result = parseLayerArchitectureYaml('''
layers:
  - data:
      level: 4
''');
      expect(result is LayerArchitectureParseFailure, isTrue);
    });

    test('fails on invalid YAML', () {
      final result = parseLayerArchitectureYaml('layers: [');
      expect(result is LayerArchitectureParseFailure, isTrue);
    });

    test('fails when level is zero', () {
      final result = parseLayerArchitectureYaml('''
layers:
  - data:
      level: 0
      path_prefix: example/data
''');
      expect(result is LayerArchitectureParseFailure, isTrue);
    });

    test('fails when level is negative', () {
      final result = parseLayerArchitectureYaml('''
layers:
  - data:
      level: -1
      path_prefix: example/data
''');
      expect(result is LayerArchitectureParseFailure, isTrue);
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
      expect(
        isLevelViolation(selfLayer: domain, dependencyLayer: usecase),
        isTrue,
      );
      expect(
        hasAnyLevelViolation(
          selfLayers: [domain],
          dependencyLayers: [usecase],
        ),
        isTrue,
      );
      expect(
        hasAnyLevelViolation(
          selfLayers: [usecase],
          dependencyLayers: [domain],
        ),
        isFalse,
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
      expect(parsed.dependencies.length, 1);
      expect(parsed.dependencies.single, 'domain_todo');
      expect(parsed.devDependencies.length, 1);
      expect(parsed.devDependencies.single, 'lints');
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
        expect(
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
      expect(matched.length, 1);
      expect(matched.single.name, 'usecase');
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
      expect(matched.length, 2);
    });
  });

  group('parseArchitectureLayerDependencyIgnore', () {
    test('missing rules yields empty success', () {
      final result = parseArchitectureLayerDependencyIgnore('layers: []\n');
      expect(result is ArchitectureLayerIgnoreParseSuccess, isTrue);
      expect(
        (result as ArchitectureLayerIgnoreParseSuccess).entries.length,
        0,
      );
    });

    test('rules without architecture_layer_dependency yields empty', () {
      final result = parseArchitectureLayerDependencyIgnore('''
rules:
  public_type_file_name:
    keywords: {}
''');
      expect(result is ArchitectureLayerIgnoreParseSuccess, isTrue);
      expect(
        (result as ArchitectureLayerIgnoreParseSuccess).entries.length,
        0,
      );
    });

    test('architecture_layer_dependency without ignore yields empty', () {
      final result = parseArchitectureLayerDependencyIgnore('''
rules:
  architecture_layer_dependency: {}
''');
      expect(result is ArchitectureLayerIgnoreParseSuccess, isTrue);
      expect(
        (result as ArchitectureLayerIgnoreParseSuccess).entries.length,
        0,
      );
    });

    test('empty ignore list yields empty success', () {
      final result = parseArchitectureLayerDependencyIgnore('''
rules:
  architecture_layer_dependency:
    ignore: []
''');
      expect(result is ArchitectureLayerIgnoreParseSuccess, isTrue);
      expect(
        (result as ArchitectureLayerIgnoreParseSuccess).entries.length,
        0,
      );
    });

    test('multiple string entries preserved in order', () {
      final result = parseArchitectureLayerDependencyIgnore('''
rules:
  architecture_layer_dependency:
    ignore:
      - a_pkg
      - b_pkg
''');
      expect(result is ArchitectureLayerIgnoreParseSuccess, isTrue);
      final entries = (result as ArchitectureLayerIgnoreParseSuccess).entries;
      expect(entries.length, 2);
      expect(entries[0], 'a_pkg');
      expect(entries[1], 'b_pkg');
    });

    test('preserves leading and trailing spaces in entry', () {
      final result = parseArchitectureLayerDependencyIgnore('''
rules:
  architecture_layer_dependency:
    ignore:
      - " pkg "
''');
      expect(result is ArchitectureLayerIgnoreParseSuccess, isTrue);
      expect(
        (result as ArchitectureLayerIgnoreParseSuccess).entries.single,
        ' pkg ',
      );
    });

    test('non-list ignore is failure', () {
      final result = parseArchitectureLayerDependencyIgnore('''
rules:
  architecture_layer_dependency:
    ignore: not_a_list
''');
      expect(result is ArchitectureLayerIgnoreParseFailure, isTrue);
    });

    test('empty string entry is failure', () {
      final result = parseArchitectureLayerDependencyIgnore('''
rules:
  architecture_layer_dependency:
    ignore:
      - ""
''');
      expect(result is ArchitectureLayerIgnoreParseFailure, isTrue);
    });

    test('non-string entry is failure', () {
      final result = parseArchitectureLayerDependencyIgnore('''
rules:
  architecture_layer_dependency:
    ignore:
      - 1
''');
      expect(result is ArchitectureLayerIgnoreParseFailure, isTrue);
    });

    test('invalid yaml is failure', () {
      // 既存 parseLayerArchitectureYaml と同じ YamlException 入力.
      final result = parseArchitectureLayerDependencyIgnore('layers: [');
      expect(result is ArchitectureLayerIgnoreParseFailure, isTrue);
    });
  });

  group('parsePackageNameFromPubspecYaml', () {
    test(
      'reads name without trimming spaces inside value only as yaml gives',
      () {
        expect(parsePackageNameFromPubspecYaml('name: foo\n'), 'foo');
      },
    );

    test('missing name returns null', () {
      expect(parsePackageNameFromPubspecYaml('description: x\n'), null);
    });
  });

  group('unresolvedIgnorePackageNames', () {
    test('returns missing names in order', () {
      final missing = unresolvedIgnorePackageNames(
        ignoreNames: ['a', 'missing', 'b', 'gone'],
        packageRoots: {'a': '/x', 'b': '/y'},
      );
      expect(missing.length, 2);
      expect(missing[0], 'missing');
      expect(missing[1], 'gone');
    });
  });

  group('shouldSkipDependencyDirectionForPackage', () {
    test('skips on exact match when valid', () {
      expect(
        shouldSkipDependencyDirectionForPackage(
          ignoreConfigValid: true,
          ignoreEntries: const ['infra_example_ignore'],
          selfPackageName: 'infra_example_ignore',
        ),
        isTrue,
      );
    });

    test('does not skip on partial match', () {
      expect(
        shouldSkipDependencyDirectionForPackage(
          ignoreConfigValid: true,
          ignoreEntries: const ['infra'],
          selfPackageName: 'infra_example_ignore',
        ),
        isFalse,
      );
    });

    test('does not skip on case mismatch', () {
      expect(
        shouldSkipDependencyDirectionForPackage(
          ignoreConfigValid: true,
          ignoreEntries: const ['Infra_Example_Ignore'],
          selfPackageName: 'infra_example_ignore',
        ),
        isFalse,
      );
    });

    test('does not skip when entry has spaces but self does not', () {
      expect(
        shouldSkipDependencyDirectionForPackage(
          ignoreConfigValid: true,
          ignoreEntries: const [' pkg '],
          selfPackageName: 'pkg',
        ),
        isFalse,
      );
    });

    test('does not skip when invalid config', () {
      expect(
        shouldSkipDependencyDirectionForPackage(
          ignoreConfigValid: false,
          ignoreEntries: const ['infra_example_ignore'],
          selfPackageName: 'infra_example_ignore',
        ),
        isFalse,
      );
    });

    test('does not skip when self name null', () {
      expect(
        shouldSkipDependencyDirectionForPackage(
          ignoreConfigValid: true,
          ignoreEntries: const ['infra_example_ignore'],
          selfPackageName: null,
        ),
        isFalse,
      );
    });
  });
}
