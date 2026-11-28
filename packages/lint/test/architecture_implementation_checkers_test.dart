import 'package:flutter_layered_architecture_lint/src/architecture_layer/architecture_implementation_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_layer/architecture_layer_checkers.dart';
import 'package:test/test.dart';

void main() {
  group('packageRoleFromPackageName', () {
    test('null → none', () {
      expect(packageRoleFromPackageName(null), PackageRole.none);
    });

    test('empty → none', () {
      expect(packageRoleFromPackageName(''), PackageRole.none);
    });

    test('data_injection → injection', () {
      expect(
        packageRoleFromPackageName('data_injection'),
        PackageRole.injection,
      );
    });

    test('data_repository_todo_impl → implementation', () {
      expect(
        packageRoleFromPackageName('data_repository_todo_impl'),
        PackageRole.implementation,
      );
    });

    test('foo_impl_injection → injection (_injection first)', () {
      expect(
        packageRoleFromPackageName('foo_impl_injection'),
        PackageRole.injection,
      );
    });

    test('foo_injection_impl → implementation', () {
      expect(
        packageRoleFromPackageName('foo_injection_impl'),
        PackageRole.implementation,
      );
    });

    test('foo_impl_extra → none (no suffix match)', () {
      expect(packageRoleFromPackageName('foo_impl_extra'), PackageRole.none);
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
  });

  group('parseArchitectureImplementationDependencyIgnore', () {
    test('missing rules yields empty', () {
      final result = parseArchitectureImplementationDependencyIgnore(
        'layers: []',
      );
      expect(result is ArchitectureImplementationIgnoreParseSuccess, isTrue);
      expect(
        (result as ArchitectureImplementationIgnoreParseSuccess).entries,
        isEmpty,
      );
    });

    test(
      'architecture_implementation_dependency without ignore yields empty',
      () {
        final result = parseArchitectureImplementationDependencyIgnore('''
rules:
  architecture_implementation_dependency: {}
''');
        expect(result is ArchitectureImplementationIgnoreParseSuccess, isTrue);
        expect(
          (result as ArchitectureImplementationIgnoreParseSuccess)
              .entries
              .length,
          0,
        );
      },
    );

    test('empty ignore list yields empty success', () {
      final result = parseArchitectureImplementationDependencyIgnore('''
rules:
  architecture_implementation_dependency:
    ignore: []
''');
      expect(result is ArchitectureImplementationIgnoreParseSuccess, isTrue);
      expect(
        (result as ArchitectureImplementationIgnoreParseSuccess).entries.length,
        0,
      );
    });

    test('multiple string entries preserved in order', () {
      final result = parseArchitectureImplementationDependencyIgnore('''
rules:
  architecture_implementation_dependency:
    ignore:
      - a_pkg
      - b_pkg
''');
      expect(result is ArchitectureImplementationIgnoreParseSuccess, isTrue);
      final entries =
          (result as ArchitectureImplementationIgnoreParseSuccess).entries;
      expect(entries.length, 2);
      expect(entries[0], 'a_pkg');
      expect(entries[1], 'b_pkg');
    });

    test('non-list ignore is failure', () {
      final result = parseArchitectureImplementationDependencyIgnore('''
rules:
  architecture_implementation_dependency:
    ignore: not_a_list
''');
      expect(result is ArchitectureImplementationIgnoreParseFailure, isTrue);
    });

    test('empty string entry is failure', () {
      final result = parseArchitectureImplementationDependencyIgnore('''
rules:
  architecture_implementation_dependency:
    ignore:
      - ""
''');
      expect(result is ArchitectureImplementationIgnoreParseFailure, isTrue);
    });

    test('non-string entry is failure', () {
      final result = parseArchitectureImplementationDependencyIgnore('''
rules:
  architecture_implementation_dependency:
    ignore:
      - 1
''');
      expect(result is ArchitectureImplementationIgnoreParseFailure, isTrue);
    });
  });

  group('shouldSkipDependencyDirectionForPackage (shared with layer)', () {
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
  });
}
