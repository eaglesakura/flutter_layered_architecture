import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_layered_architecture_lint/src/file_layout/public_api_checkers.dart';

/// `package:test` は workspace の flutter_test / analyzer ^8 と解決不能なため、
/// assert ベースのランナーで unit test 相当を実行する.
///
/// 実行: `dart run test/public_api_checkers_test.dart`
void main() {
  group('packageLibRootOf', () {
    test('returns lib root for src path', () {
      expectEquals(
        packageLibRootOf('/pkg/lib/src/foo.dart'),
        '/pkg/lib',
      );
    });
    test('returns lib root for barrel path', () {
      expectEquals(
        packageLibRootOf('/pkg/lib/foo.dart'),
        '/pkg/lib',
      );
    });
    test('returns null when lib is absent', () {
      expectEquals(packageLibRootOf('/pkg/test/foo.dart'), null);
    });
  });

  group('isLibRootDartFile', () {
    test('true for lib/*.dart', () {
      expectTrue(isLibRootDartFile('/pkg/lib/screen_feature_todo_list.dart'));
    });
    test('false for lib/src/*.dart', () {
      expectFalse(isLibRootDartFile('/pkg/lib/src/todo_list_screen.dart'));
    });
    test('false for nested lib paths', () {
      expectFalse(isLibRootDartFile('/pkg/lib/view/foo.dart'));
    });
  });

  group('hasLibraryDirective', () {
    test('detects library;', () {
      final unit = parseString(content: 'library;\n').unit;
      expectTrue(hasLibraryDirective(unit));
    });
    test('detects named library', () {
      final unit = parseString(content: 'library foo;\n').unit;
      expectTrue(hasLibraryDirective(unit));
    });
    test('false when missing', () {
      final unit = parseString(
        content: "export 'src/a.dart';\n",
      ).unit;
      expectFalse(hasLibraryDirective(unit));
    });
  });

  group('applyExportCombinators', () {
    test('returns all names when combinators empty', () {
      final unit = parseString(
        content: "export 'a.dart';\n",
      ).unit;
      final export = unit.directives.whereType<ExportDirective>().single;
      expectEquals(
        applyExportCombinators({'A', 'B'}, export.combinators).toList()..sort(),
        ['A', 'B'],
      );
    });
  });

  group('resolveExportUri', () {
    test('resolves relative uri', () {
      expectEquals(
        resolveExportUri(
          uri: 'src/todo.dart',
          fromFilePath: '/pkg/lib/domain_todo.dart',
          libRoot: '/pkg/lib',
          packageName: 'domain_todo',
        ),
        '/pkg/lib/src/todo.dart',
      );
    });
    test('resolves same-package package uri', () {
      expectEquals(
        resolveExportUri(
          uri: 'package:domain_todo/src/todo.dart',
          fromFilePath: '/pkg/lib/domain_todo.dart',
          libRoot: '/pkg/lib',
          packageName: 'domain_todo',
        ),
        '/pkg/lib/src/todo.dart',
      );
    });
  });

  group('publicTopLevelSymbolsOf', () {
    test('includes class enum function typedef and variable', () {
      final unit = parseString(
        content: '''
final class Foo {}
enum Bar { a }
void doWork() {}
typedef Callback = void Function();
const int answer = 42;
final class _Hidden {}
''',
      ).unit;

      final names = publicTopLevelSymbolsOf(
        unit,
      ).map((symbol) => symbol.name.lexeme).toList(growable: false);
      expectEquals(names, ['Foo', 'Bar', 'doWork', 'Callback', 'answer']);
    });

    test('includes named extension and skips unnamed', () {
      final unit = parseString(
        content: '''
extension FooX on int {
  int get doubled => this * 2;
}

extension on String {
  int get len => length;
}
''',
      ).unit;
      final names = publicTopLevelSymbolsOf(
        unit,
      ).map((symbol) => symbol.name.lexeme).toList(growable: false);
      expectEquals(names, ['FooX']);
    });
  });

  // ignore: avoid_print
  print('All public_api_checkers tests passed.');
}

void expectEquals(Object? actual, Object? expected) {
  if (actual is List && expected is List) {
    if (actual.length != expected.length) {
      throw Exception('Expected: <$expected>\n  Actual: <$actual>');
    }
    for (var i = 0; i < actual.length; i++) {
      if (actual[i] != expected[i]) {
        throw Exception('Expected: <$expected>\n  Actual: <$actual>');
      }
    }
    return;
  }
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
