import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_layered_architecture_lint/src/file_layout/public_api_checkers.dart';
import 'package:test/test.dart';

void main() {
  group('packageLibRootOf', () {
    test('returns lib root for src path', () {
      expect(
        packageLibRootOf('/pkg/lib/src/foo.dart'),
        '/pkg/lib',
      );
    });
    test('returns lib root for barrel path', () {
      expect(
        packageLibRootOf('/pkg/lib/foo.dart'),
        '/pkg/lib',
      );
    });
    test('returns null when lib is absent', () {
      expect(packageLibRootOf('/pkg/test/foo.dart'), null);
    });
  });

  group('isLibRootDartFile', () {
    test('true for lib/*.dart', () {
      expect(
        isLibRootDartFile('/pkg/lib/screen_feature_todo_list.dart'),
        isTrue,
      );
    });
    test('false for lib/src/*.dart', () {
      expect(isLibRootDartFile('/pkg/lib/src/todo_list_screen.dart'), isFalse);
    });
    test('false for nested lib paths', () {
      expect(isLibRootDartFile('/pkg/lib/view/foo.dart'), isFalse);
    });
  });

  group('hasLibraryDirective', () {
    test('detects library;', () {
      final unit = parseString(content: 'library;\n').unit;
      expect(hasLibraryDirective(unit), isTrue);
    });
    test('detects named library', () {
      final unit = parseString(content: 'library foo;\n').unit;
      expect(hasLibraryDirective(unit), isTrue);
    });
    test('false when missing', () {
      final unit = parseString(
        content: "export 'src/a.dart';\n",
      ).unit;
      expect(hasLibraryDirective(unit), isFalse);
    });
  });

  group('applyExportCombinators', () {
    test('returns all names when combinators empty', () {
      final unit = parseString(
        content: "export 'a.dart';\n",
      ).unit;
      final export = unit.directives.whereType<ExportDirective>().single;
      expect(
        applyExportCombinators({'A', 'B'}, export.combinators).toList()..sort(),
        ['A', 'B'],
      );
    });
  });

  group('resolveExportUri', () {
    test('resolves relative uri', () {
      expect(
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
      expect(
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
      expect(names, ['Foo', 'Bar', 'doWork', 'Callback', 'answer']);
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
      expect(names, ['FooX']);
    });
  });
}
