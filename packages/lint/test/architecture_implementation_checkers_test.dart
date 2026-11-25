import 'dart:io';

import 'package:flutter_layered_architecture_lint/src/architecture_layer/architecture_implementation_checkers.dart';
import 'package:path/path.dart' as p;

/// `package:test` は workspace の flutter_test / analyzer ^8 と解決不能なため、
/// assert ベースのランナーで unit test 相当を実行する.
///
/// 実行: `dart run test/architecture_implementation_checkers_test.dart`
void main() {
  group('annotationsFromBarrelSource', () {
    test('@injection library → hasInjection', () {
      final flags = annotationsFromBarrelSource('@injection\nlibrary;\n');
      expectTrue(flags.hasInjection);
      expectFalse(flags.hasImplementation);
    });

    test('@implementation library → hasImplementation', () {
      final flags = annotationsFromBarrelSource('@implementation\nlibrary;\n');
      expectFalse(flags.hasInjection);
      expectTrue(flags.hasImplementation);
    });

    test('both annotations → both flags', () {
      final flags = annotationsFromBarrelSource(
        '@injection\n@implementation\nlibrary;\n',
      );
      expectTrue(flags.hasInjection);
      expectTrue(flags.hasImplementation);
    });

    test('export only without library → none', () {
      final flags = annotationsFromBarrelSource("export 'a.dart';\n");
      expectFalse(flags.hasInjection);
      expectFalse(flags.hasImplementation);
    });
  });

  group('detectPackageRole', () {
    test('lib/src annotation only → none (barrel not scanned)', () {
      final tempDir = Directory.systemTemp.createTempSync(
        'arch_impl_role_src_',
      );
      try {
        final packageRoot = p.join(tempDir.path, 'my_pkg');
        final libSrc = p.join(packageRoot, 'lib', 'src');
        Directory(libSrc).createSync(recursive: true);
        File(p.join(libSrc, 'x.dart')).writeAsStringSync(
          '@injection\nlibrary;\n',
        );
        expectEquals(
          detectPackageRole(
            packageRootPath: packageRoot,
            readTextFile: (path) => File(path).readAsStringSync(),
          ),
          PackageRole.none,
        );
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('lib barrel with @injection → injection', () {
      final tempDir = Directory.systemTemp.createTempSync(
        'arch_impl_role_inj_',
      );
      try {
        final packageRoot = p.join(tempDir.path, 'inj_pkg');
        final libDir = p.join(packageRoot, 'lib');
        Directory(libDir).createSync(recursive: true);
        File(p.join(libDir, 'inj_pkg.dart'))
            .writeAsStringSync('@injection\nlibrary;\n');
        expectEquals(
          detectPackageRole(
            packageRootPath: packageRoot,
            readTextFile: (path) => File(path).readAsStringSync(),
          ),
          PackageRole.injection,
        );
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });

  group('isImplementationDependencyAllowed', () {
    test('injection + same layer + implementation → allowed', () {
      expectTrue(
        isImplementationDependencyAllowed(
          selfRole: PackageRole.injection,
          selfLayerName: 'data',
          dependencyRole: PackageRole.implementation,
          dependencyLayerName: 'data',
        ),
      );
    });

    test('none + implementation → denied', () {
      expectFalse(
        isImplementationDependencyAllowed(
          selfRole: PackageRole.none,
          selfLayerName: 'data',
          dependencyRole: PackageRole.implementation,
          dependencyLayerName: 'data',
        ),
      );
    });

    test('injection + different layer + implementation → denied', () {
      expectFalse(
        isImplementationDependencyAllowed(
          selfRole: PackageRole.injection,
          selfLayerName: 'data',
          dependencyRole: PackageRole.implementation,
          dependencyLayerName: 'usecase',
        ),
      );
    });

    test('injection + dependency none → allowed (rule N/A)', () {
      expectTrue(
        isImplementationDependencyAllowed(
          selfRole: PackageRole.injection,
          selfLayerName: 'data',
          dependencyRole: PackageRole.none,
          dependencyLayerName: 'data',
        ),
      );
    });

    test('injection + same layer + both → allowed', () {
      expectTrue(
        isImplementationDependencyAllowed(
          selfRole: PackageRole.injection,
          selfLayerName: 'data',
          dependencyRole: PackageRole.both,
          dependencyLayerName: 'data',
        ),
      );
    });

    test('none + both → denied', () {
      expectFalse(
        isImplementationDependencyAllowed(
          selfRole: PackageRole.none,
          selfLayerName: 'data',
          dependencyRole: PackageRole.both,
          dependencyLayerName: 'data',
        ),
      );
    });
  });

  // ignore: avoid_print
  print('All architecture_implementation_checkers tests passed.');
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
