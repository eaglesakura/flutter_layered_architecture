import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:flutter_layered_architecture_lint/src/file_layout/file_layout_checkers.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('pascalToSnakeCase', () {
    test('converts AddTodoUsecase', () {
      expect(pascalToSnakeCase('AddTodoUsecase'), 'add_todo_usecase');
    });
    test('converts single segment Todo', () {
      expect(pascalToSnakeCase('Todo'), 'todo');
    });
    test('converts consecutive capitals HTTPClient', () {
      expect(pascalToSnakeCase('HTTPClient'), 'http_client');
    });
  });

  group('pascalCaseSegments', () {
    test('splits AddTodoUseCase', () {
      final segments = pascalCaseSegments('AddTodoUseCase');
      expect(segments.length, 4);
      expect(segments[0], 'Add');
      expect(segments[1], 'Todo');
      expect(segments[2], 'Use');
      expect(segments[3], 'Case');
    });

    test('keeps Usecase as one segment', () {
      final segments = pascalCaseSegments('AddTodoUsecase');
      expect(segments.length, 3);
      expect(segments[0], 'Add');
      expect(segments[1], 'Todo');
      expect(segments[2], 'Usecase');
    });

    test('splits HTTPClient', () {
      final segments = pascalCaseSegments('HTTPClient');
      expect(segments.length, 2);
      expect(segments[0], 'HTTP');
      expect(segments[1], 'Client');
    });
  });

  group('expectedFileNameForType', () {
    test('appends .dart to snake_case name', () {
      expect(
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
      expect(
        expectedFileNameForType('AddTodoUseCase'),
        'add_todo_use_case.dart',
      );
    });

    test('UseCase maps to usecase', () {
      expect(
        expectedFileNameForType(
          'AddTodoUseCase',
          keywords: [useCaseKeyword],
        ),
        'add_todo_usecase.dart',
      );
    });

    test('ViewModel maps to viewmodel', () {
      expect(
        expectedFileNameForType(
          'TodoListViewModel',
          keywords: [viewModelKeyword],
        ),
        'todo_list_viewmodel.dart',
      );
    });

    test('Usecase spelling does not match UseCase', () {
      expect(
        expectedFileNameForType(
          'AddTodoUsecase',
          keywords: [useCaseKeyword],
        ),
        'add_todo_usecase.dart',
      );
    });

    test('non-matching AddTodoRequest', () {
      expect(
        expectedFileNameForType(
          'AddTodoRequest',
          keywords: [useCaseKeyword],
        ),
        'add_todo_request.dart',
      );
    });

    test('keyword at start', () {
      expect(
        expectedFileNameForType('UseCase', keywords: [useCaseKeyword]),
        'usecase.dart',
      );
    });

    test('keyword at end', () {
      expect(
        expectedFileNameForType('FooUseCase', keywords: [useCaseKeyword]),
        'foo_usecase.dart',
      );
    });

    test('keyword then suffix', () {
      expect(
        expectedFileNameForType('UseCaseFoo', keywords: [useCaseKeyword]),
        'usecase_foo.dart',
      );
    });

    test('same keyword twice', () {
      expect(
        expectedFileNameForType(
          'UseCaseFooUseCase',
          keywords: [useCaseKeyword],
        ),
        'usecase_foo_usecase.dart',
      );
    });

    test('two keywords', () {
      expect(
        expectedFileNameForType(
          'AddTodoUseCaseViewModel',
          keywords: [useCaseKeyword, viewModelKeyword],
        ),
        'add_todo_usecase_viewmodel.dart',
      );
    });

    test('declaration order Case first', () {
      const caseKeyword = (keySegments: ['Case'], replacement: 'case');
      expect(
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
      expect(
        expectedFileNameForType(
          'AddTodoUseCase',
          keywords: [underscoreKeyword],
        ),
        'add_todo_use_case.dart',
      );
    });

    test('HTTPClient without keywords', () {
      expect(
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
      expect(keywords.length, 2);
      expect(keywords[0].keySegments.length, 2);
      expect(keywords[0].keySegments[0], 'Use');
      expect(keywords[0].keySegments[1], 'Case');
      expect(keywords[0].replacement, 'usecase');
      expect(keywords[1].keySegments.length, 2);
      expect(keywords[1].keySegments[0], 'View');
      expect(keywords[1].keySegments[1], 'Model');
      expect(keywords[1].replacement, 'viewmodel');
    });

    test('missing rules yields empty', () {
      expect(parsePublicTypeFileNameKeywords('layers: []').length, 0);
    });

    test('empty rules map yields empty', () {
      expect(parsePublicTypeFileNameKeywords('rules: {}').length, 0);
    });

    test('empty rule config yields empty', () {
      expect(
        parsePublicTypeFileNameKeywords('''
rules:
  public_type_file_name: {}
''').length,
        0,
      );
    });

    test('empty keywords map yields empty', () {
      expect(
        parsePublicTypeFileNameKeywords('''
rules:
  public_type_file_name:
    keywords: {}
''').length,
        0,
      );
    });

    test('invalid yaml yields empty', () {
      expect(parsePublicTypeFileNameKeywords('rules: [').length, 0);
    });

    test('skips empty string value', () {
      expect(
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
        expect(resolveFileNameKeywordsForPath(dartFile).length, 0);
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
        expect(keywords.length, 2);
        expect(keywords[0].keySegments.length, 2);
        expect(keywords[0].keySegments[0], 'Use');
        expect(keywords[0].keySegments[1], 'Case');
        expect(keywords[0].replacement, 'usecase');
        expect(keywords[1].keySegments.length, 2);
        expect(keywords[1].keySegments[0], 'View');
        expect(keywords[1].keySegments[1], 'Model');
        expect(keywords[1].replacement, 'viewmodel');
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });

  group('isUnderTestDirectory', () {
    test('returns false for lib path', () {
      expect(
        isUnderTestDirectory('/pkg/lib/src/add_todo_usecase.dart'),
        isFalse,
      );
    });
    test('returns true for test path', () {
      expect(isUnderTestDirectory('/pkg/test/usecase_lint_probe.dart'), isTrue);
    });
    test('handles Windows separators', () {
      expect(isUnderTestDirectory(r'C:\pkg\test\probe.dart'), isTrue);
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
      expect(types.length, 2);
      expect(types[0].name.lexeme, 'AddTodoRequest');
      expect(types[1].name.lexeme, 'AddTodoUsecase');
      // Splitting is required: one_public_type_per_file would fire on 2nd+.
      expect(types.length >= 2, isTrue);
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
      expect(publicNamedTypesOf(unit).length, 1);
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
      expect(publicNamedTypesOf(unit).length, 0);
    });

    test('ignores typedef', () {
      final unit = parseString(
        content: '''
typedef Callback = void Function();
typedef IntList = List<int>;
''',
      ).unit;
      expect(publicNamedTypesOf(unit).length, 0);
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
      expect(types.length, 1);
      expect(types.single.name.lexeme, 'StringX');
    });

    test('ignores unnamed extension', () {
      final unit = parseString(
        content: '''
extension on String {
  String get doubled => this + this;
}
''',
      ).unit;
      expect(publicNamedTypesOf(unit).length, 0);
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
      expect(types.length, 1);
      expect(
        expectedFileNameForType(types.single.name.lexeme),
        'add_todo_usecase.dart',
      );
      expect(
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
      expect(types.length, 1);
      expect(
        fileBasename('/pkg/lib/src/add_todo_usecase.dart') !=
            expectedFileNameForType(types.single.name.lexeme),
        isTrue,
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
      expect(hasPartOfDirective(unit), isTrue);
    });

    test('returns false for normal library files', () {
      final unit = parseString(
        content: '''
final class Foo {
  const Foo();
}
''',
      ).unit;
      expect(hasPartOfDirective(unit), isFalse);
    });
  });
}
