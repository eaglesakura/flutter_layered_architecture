import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:flutter_layered_architecture_lint/src/file_layout/file_layout_checkers.dart';
import 'package:path/path.dart' as p;

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

  group('pascalCaseSegments', () {
    test('splits AddTodoUseCase', () {
      final segments = pascalCaseSegments('AddTodoUseCase');
      expectEquals(segments.length, 4);
      expectEquals(segments[0], 'Add');
      expectEquals(segments[1], 'Todo');
      expectEquals(segments[2], 'Use');
      expectEquals(segments[3], 'Case');
    });

    test('keeps Usecase as one segment', () {
      final segments = pascalCaseSegments('AddTodoUsecase');
      expectEquals(segments.length, 3);
      expectEquals(segments[0], 'Add');
      expectEquals(segments[1], 'Todo');
      expectEquals(segments[2], 'Usecase');
    });

    test('splits HTTPClient', () {
      final segments = pascalCaseSegments('HTTPClient');
      expectEquals(segments.length, 2);
      expectEquals(segments[0], 'HTTP');
      expectEquals(segments[1], 'Client');
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

  group('expectedFileNameForType with keywords', () {
    const useCaseKeyword = (
      keySegments: ['Use', 'Case'],
      replacement: 'usecase',
    );
    const viewModelKeyword = (
      keySegments: ['View', 'Model'],
      replacement: 'viewmodel',
    );

    test('empty keywords AddTodoUseCase', () {
      expectEquals(
        expectedFileNameForType('AddTodoUseCase'),
        'add_todo_use_case.dart',
      );
    });

    test('UseCase maps to usecase', () {
      expectEquals(
        expectedFileNameForType(
          'AddTodoUseCase',
          keywords: [useCaseKeyword],
        ),
        'add_todo_usecase.dart',
      );
    });

    test('ViewModel maps to viewmodel', () {
      expectEquals(
        expectedFileNameForType(
          'TodoListViewModel',
          keywords: [viewModelKeyword],
        ),
        'todo_list_viewmodel.dart',
      );
    });

    test('Usecase spelling does not match UseCase', () {
      expectEquals(
        expectedFileNameForType(
          'AddTodoUsecase',
          keywords: [useCaseKeyword],
        ),
        'add_todo_usecase.dart',
      );
    });

    test('non-matching AddTodoRequest', () {
      expectEquals(
        expectedFileNameForType(
          'AddTodoRequest',
          keywords: [useCaseKeyword],
        ),
        'add_todo_request.dart',
      );
    });

    test('keyword at start', () {
      expectEquals(
        expectedFileNameForType('UseCase', keywords: [useCaseKeyword]),
        'usecase.dart',
      );
    });

    test('keyword at end', () {
      expectEquals(
        expectedFileNameForType('FooUseCase', keywords: [useCaseKeyword]),
        'foo_usecase.dart',
      );
    });

    test('keyword then suffix', () {
      expectEquals(
        expectedFileNameForType('UseCaseFoo', keywords: [useCaseKeyword]),
        'usecase_foo.dart',
      );
    });

    test('same keyword twice', () {
      expectEquals(
        expectedFileNameForType(
          'UseCaseFooUseCase',
          keywords: [useCaseKeyword],
        ),
        'usecase_foo_usecase.dart',
      );
    });

    test('two keywords', () {
      expectEquals(
        expectedFileNameForType(
          'AddTodoUseCaseViewModel',
          keywords: [useCaseKeyword, viewModelKeyword],
        ),
        'add_todo_usecase_viewmodel.dart',
      );
    });

    test('declaration order Case first', () {
      const caseKeyword = (keySegments: ['Case'], replacement: 'case');
      expectEquals(
        expectedFileNameForType(
          'AddTodoUseCase',
          keywords: [caseKeyword, useCaseKeyword],
        ),
        'add_todo_use_case.dart',
      );
    });

    test('replacement with underscore', () {
      const underscoreKeyword = (
        keySegments: ['Use', 'Case'],
        replacement: 'use_case',
      );
      expectEquals(
        expectedFileNameForType(
          'AddTodoUseCase',
          keywords: [underscoreKeyword],
        ),
        'add_todo_use_case.dart',
      );
    });

    test('HTTPClient without keywords', () {
      expectEquals(
        expectedFileNameForType('HTTPClient'),
        'http_client.dart',
      );
    });
  });

  group('parsePublicTypeFileNameKeywords', () {
    test('parses two keywords in order', () {
      const yamlText = '''
rules:
  public_type_file_name:
    keywords:
      UseCase: usecase
      ViewModel: viewmodel
''';
      final keywords = parsePublicTypeFileNameKeywords(yamlText);
      expectEquals(keywords.length, 2);
      expectEquals(keywords[0].keySegments.length, 2);
      expectEquals(keywords[0].keySegments[0], 'Use');
      expectEquals(keywords[0].keySegments[1], 'Case');
      expectEquals(keywords[0].replacement, 'usecase');
      expectEquals(keywords[1].keySegments.length, 2);
      expectEquals(keywords[1].keySegments[0], 'View');
      expectEquals(keywords[1].keySegments[1], 'Model');
      expectEquals(keywords[1].replacement, 'viewmodel');
    });

    test('missing rules yields empty', () {
      expectEquals(parsePublicTypeFileNameKeywords('layers: []').length, 0);
    });

    test('empty rules map yields empty', () {
      expectEquals(parsePublicTypeFileNameKeywords('rules: {}').length, 0);
    });

    test('empty rule config yields empty', () {
      expectEquals(
        parsePublicTypeFileNameKeywords('''
rules:
  public_type_file_name: {}
''').length,
        0,
      );
    });

    test('empty keywords map yields empty', () {
      expectEquals(
        parsePublicTypeFileNameKeywords('''
rules:
  public_type_file_name:
    keywords: {}
''').length,
        0,
      );
    });

    test('invalid yaml yields empty', () {
      expectEquals(parsePublicTypeFileNameKeywords('rules: [').length, 0);
    });

    test('skips empty string value', () {
      expectEquals(
        parsePublicTypeFileNameKeywords('''
rules:
  public_type_file_name:
    keywords:
      UseCase: ""
''').length,
        0,
      );
    });
  });

  group('resolveFileNameKeywordsForPath', () {
    test('missing yaml yields empty', () {
      final tempDir = Directory.systemTemp.createTempSync('file_layout_kw_');
      try {
        final packageRoot = p.join(tempDir.path, 'my_pkg');
        Directory(p.join(packageRoot, 'lib')).createSync(recursive: true);
        File(p.join(packageRoot, 'pubspec.yaml'))
            .writeAsStringSync('name: my_pkg\n');
        final dartFile = p.join(packageRoot, 'lib', 'x.dart');
        File(dartFile).writeAsStringSync('void main() {}');
        expectEquals(resolveFileNameKeywordsForPath(dartFile).length, 0);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('reads keywords from layered_architecture.yaml', () {
      final tempDir = Directory.systemTemp.createTempSync('file_layout_kw_');
      try {
        final packageRoot = p.join(tempDir.path, 'my_pkg');
        Directory(p.join(packageRoot, 'lib')).createSync(recursive: true);
        File(p.join(packageRoot, 'pubspec.yaml'))
            .writeAsStringSync('name: my_pkg\n');
        File(p.join(packageRoot, 'layered_architecture.yaml'))
            .writeAsStringSync(
              '''
rules:
  public_type_file_name:
    keywords:
      UseCase: usecase
      ViewModel: viewmodel
''',
            );
        final dartFile = p.join(packageRoot, 'lib', 'x.dart');
        File(dartFile).writeAsStringSync('void main() {}');
        final keywords = resolveFileNameKeywordsForPath(dartFile);
        expectEquals(keywords.length, 2);
        expectEquals(keywords[0].keySegments.length, 2);
        expectEquals(keywords[0].keySegments[0], 'Use');
        expectEquals(keywords[0].keySegments[1], 'Case');
        expectEquals(keywords[0].replacement, 'usecase');
        expectEquals(keywords[1].keySegments.length, 2);
        expectEquals(keywords[1].keySegments[0], 'View');
        expectEquals(keywords[1].keySegments[1], 'Model');
        expectEquals(keywords[1].replacement, 'viewmodel');
      } finally {
        tempDir.deleteSync(recursive: true);
      }
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
