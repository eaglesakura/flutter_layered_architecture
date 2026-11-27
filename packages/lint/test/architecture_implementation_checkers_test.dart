import 'dart:io';

import 'package:flutter_layered_architecture_lint/src/architecture_layer/architecture_implementation_checkers.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('annotationsFromBarrelSource', () {
    test('@injection library → hasInjection', () {
      final flags = annotationsFromBarrelSource('@injection\nlibrary;\n');
      expect(flags.hasInjection, isTrue);
      expect(flags.hasImplementation, isFalse);
    });

    test('@implementation library → hasImplementation', () {
      final flags = annotationsFromBarrelSource('@implementation\nlibrary;\n');
      expect(flags.hasInjection, isFalse);
      expect(flags.hasImplementation, isTrue);
    });

    test('both annotations → both flags', () {
      final flags = annotationsFromBarrelSource(
        '@injection\n@implementation\nlibrary;\n',
      );
      expect(flags.hasInjection, isTrue);
      expect(flags.hasImplementation, isTrue);
    });

    test('export only without library → none', () {
      final flags = annotationsFromBarrelSource("export 'a.dart';\n");
      expect(flags.hasInjection, isFalse);
      expect(flags.hasImplementation, isFalse);
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
        expect(
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
        expect(
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
      expect(
        isImplementationDependencyAllowed(
          selfRole: PackageRole.injection,
          selfLayerName: 'data',
          dependencyRole: PackageRole.implementation,
          dependencyLayerName: 'data',
        ),
        isTrue,
      );
    });

    test('none + implementation → denied', () {
      expect(
        isImplementationDependencyAllowed(
          selfRole: PackageRole.none,
          selfLayerName: 'data',
          dependencyRole: PackageRole.implementation,
          dependencyLayerName: 'data',
        ),
        isFalse,
      );
    });

    test('injection + different layer + implementation → denied', () {
      expect(
        isImplementationDependencyAllowed(
          selfRole: PackageRole.injection,
          selfLayerName: 'data',
          dependencyRole: PackageRole.implementation,
          dependencyLayerName: 'usecase',
        ),
        isFalse,
      );
    });

    test('injection + dependency none → allowed (rule N/A)', () {
      expect(
        isImplementationDependencyAllowed(
          selfRole: PackageRole.injection,
          selfLayerName: 'data',
          dependencyRole: PackageRole.none,
          dependencyLayerName: 'data',
        ),
        isTrue,
      );
    });

    test('injection + same layer + both → allowed', () {
      expect(
        isImplementationDependencyAllowed(
          selfRole: PackageRole.injection,
          selfLayerName: 'data',
          dependencyRole: PackageRole.both,
          dependencyLayerName: 'data',
        ),
        isTrue,
      );
    });

    test('none + both → denied', () {
      expect(
        isImplementationDependencyAllowed(
          selfRole: PackageRole.none,
          selfLayerName: 'data',
          dependencyRole: PackageRole.both,
          dependencyLayerName: 'data',
        ),
        isFalse,
      );
    });
  });
}
