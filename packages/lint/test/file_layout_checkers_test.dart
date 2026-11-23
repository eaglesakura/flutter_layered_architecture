import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:flutter_layered_architecture_lint/src/file_layout/file_layout_checkers.dart';

/// `package:test` は workspace の flutter_test / analyzer ^8 と解決不能なため、
/// assert ベースのランナーで unit test 相当を実行する.
///
/// 実行: `dart run test/file_layout_checkers_test.dart`
void main() {
  group('pascalToSnakeCase', () {
    test('converts AddTodoUsecase', () {
      expectEquals(pascalToSnakeCase('AddTodoUsecase'), 'add_todo_usecase');
    });
    test('converts single segment Todo', () {
      expectEquals(pascalToSnakeCase('Todo'), 'todo');
    });
    test('converts consecutive capitals HTTPClient', () {
      expectEquals(pascalToSnakeCase('HTTPClient'), 'http_client');
    });
  });

  group('expectedFileNameForType', () {
    test('appends .dart to snake_case name', () {
      expectEquals(
        expectedFileNameForType('AddTodoRequest'),
        'add_todo_request.dart',
      );
    });
  });

  group('isUnderTestDirectory', () {
    test('returns false for lib path', () {
      expectFalse(isUnderTestDirectory('/pkg/lib/src/add_todo_usecase.dart'));
    });
    test('returns true for test path', () {
      expectTrue(isUnderTestDirectory('/pkg/test/usecase_lint_probe.dart'));
    });
    test('handles Windows separators', () {
      expectTrue(isUnderTestDirectory(r'C:\pkg\test\probe.dart'));
    });
  });

  group('publicNamedTypesOf', () {
    test('flags Request+Usecase co-location as two public types', () {
      final unit = parseString(
        content: '''
final class AddTodoRequest {
  const AddTodoRequest();
}

abstract interface class AddTodoUsecase {
  const AddTodoUsecase();
}
''',
      ).unit;

      final types = publicNamedTypesOf(unit).toList(growable: false);
      expectEquals(types.length, 2);
      expectEquals(types[0].name.lexeme, 'AddTodoRequest');
      expectEquals(types[1].name.lexeme, 'AddTodoUsecase');
      // Splitting is required: one_public_type_per_file would fire on 2nd+.
      expectTrue(types.length >= 2);
    });

    test('allows one public type with private helpers', () {
      final unit = parseString(
        content: '''
final class Foo {
  const Foo();
}

final class _Helper {
  const _Helper();
}

final class _Another {
  const _Another();
}
''',
      ).unit;
      expectEquals(publicNamedTypesOf(unit).length, 1);
    });

    test('allows zero public types', () {
      final unit = parseString(
        content: '''
final class _OnlyPrivate {
  const _OnlyPrivate();
}

void topLevel() {}
''',
      ).unit;
      expectEquals(publicNamedTypesOf(unit).length, 0);
    });

    test('ignores typedef', () {
      final unit = parseString(
        content: '''
typedef Callback = void Function();
typedef IntList = List<int>;
''',
      ).unit;
      expectEquals(publicNamedTypesOf(unit).length, 0);
    });

    test('counts named extension as one public type', () {
      final unit = parseString(
        content: '''
extension StringX on String {
  String get doubled => this + this;
}
''',
      ).unit;
      final types = publicNamedTypesOf(unit).toList(growable: false);
      expectEquals(types.length, 1);
      expectEquals(types.single.name.lexeme, 'StringX');
    });

    test('ignores unnamed extension', () {
      final unit = parseString(
        content: '''
extension on String {
  String get doubled => this + this;
}
''',
      ).unit;
      expectEquals(publicNamedTypesOf(unit).length, 0);
    });
  });

  group('file name match helpers', () {
    test('matching basename for single public type', () {
      final unit = parseString(
        content: '''
final class AddTodoUsecase {
  const AddTodoUsecase();
}
''',
      ).unit;
      final types = publicNamedTypesOf(unit).toList(growable: false);
      expectEquals(types.length, 1);
      expectEquals(
        expectedFileNameForType(types.single.name.lexeme),
        'add_todo_usecase.dart',
      );
      expectEquals(
        fileBasename('/pkg/lib/src/add_todo_usecase.dart'),
        expectedFileNameForType(types.single.name.lexeme),
      );
    });

    test('mismatching basename is detectable', () {
      final unit = parseString(
        content: '''
final class AddTodoRequest {
  const AddTodoRequest();
}
''',
      ).unit;
      final types = publicNamedTypesOf(unit).toList(growable: false);
      expectEquals(types.length, 1);
      expectTrue(
        fileBasename('/pkg/lib/src/add_todo_usecase.dart') !=
            expectedFileNameForType(types.single.name.lexeme),
      );
    });
  });

  group('hasPartOfDirective', () {
    test('detects part of', () {
      final unit = parseString(
        content: '''
part of 'library.dart';

final class Generated {
  const Generated();
}
''',
      ).unit;
      expectTrue(hasPartOfDirective(unit));
    });

    test('returns false for normal library files', () {
      final unit = parseString(
        content: '''
final class Foo {
  const Foo();
}
''',
      ).unit;
      expectFalse(hasPartOfDirective(unit));
    });
  });

  // ignore: avoid_print
  print('All file_layout_checkers tests passed.');
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
