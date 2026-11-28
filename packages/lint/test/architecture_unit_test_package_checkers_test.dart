import 'package:flutter_layered_architecture_lint/src/architecture_layer/architecture_layer_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_layer/architecture_unit_test_package_checkers.dart';
import 'package:test/test.dart';

void main() {
  group('isUnitTestPackageName', () {
    test('endsWith _test', () {
      expect(isUnitTestPackageName('foo_test'), isTrue);
      expect(isUnitTestPackageName('usecase_todo_test'), isTrue);
    });

    test('does not match _testing or middle _test', () {
      expect(isUnitTestPackageName('foo_testing'), isFalse);
      expect(isUnitTestPackageName('foo_test_utils'), isFalse);
      expect(isUnitTestPackageName('testing_core'), isFalse);
    });
  });

  group('support name helpers', () {
    test('layer testing support endsWith _testing', () {
      expect(isLayerTestingSupportPackageName('foo_testing'), isTrue);
      expect(isLayerTestingSupportPackageName('foo_test'), isFalse);
    });

    test('shared testing support startsWith testing_', () {
      expect(isSharedTestingSupportPackageName('testing_core'), isTrue);
      expect(isSharedTestingSupportPackageName('core_testing'), isFalse);
    });
  });

  group('isForbiddenUnitTestPackageDependency', () {
    const definitionDir = '/ws';
    const domain = ArchitectureLayer(
      name: 'domain',
      level: 2,
      pathPrefix: 'example/domain',
    );
    const data = ArchitectureLayer(
      name: 'data',
      level: 4,
      pathPrefix: 'example/data',
    );
    const dataChild = ArchitectureLayer(
      name: 'data_child',
      level: 4,
      pathPrefix: 'example/data/repository',
    );

    test('true when *_test and single in-layer root', () {
      expect(
        isForbiddenUnitTestPackageDependency(
          definitionDir: definitionDir,
          layers: [domain, data],
          dependencyName: 'domain_todo_test',
          dependencyRootPath: '/ws/example/domain/todo/_test',
        ),
        isTrue,
      );
    });

    test('false when name endsWith _testing', () {
      expect(
        isForbiddenUnitTestPackageDependency(
          definitionDir: definitionDir,
          layers: [domain],
          dependencyName: 'domain_todo_testing',
          dependencyRootPath: '/ws/example/domain/todo/_testing',
        ),
        isFalse,
      );
    });

    test('false when dependency root is null', () {
      expect(
        isForbiddenUnitTestPackageDependency(
          definitionDir: definitionDir,
          layers: [domain],
          dependencyName: 'domain_todo_test',
          dependencyRootPath: null,
        ),
        isFalse,
      );
    });

    test('false when out of architecture', () {
      expect(
        isForbiddenUnitTestPackageDependency(
          definitionDir: definitionDir,
          layers: [domain],
          dependencyName: 'external_test',
          dependencyRootPath: '/ws/packages/external_test',
        ),
        isFalse,
      );
    });

    test('false when ambiguous multiple layers', () {
      expect(
        isForbiddenUnitTestPackageDependency(
          definitionDir: definitionDir,
          layers: [data, dataChild],
          dependencyName: 'data_repo_test',
          dependencyRootPath: '/ws/example/data/repository/todo/_test',
        ),
        isFalse,
      );
    });
  });
}
