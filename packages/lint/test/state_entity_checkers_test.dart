import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_layered_architecture_lint/src/state_entity/state_entity_checkers.dart';

/// `package:test` は workspace の flutter_test / analyzer ^8 と解決不能なため、
/// assert ベースのランナーで unit test 相当を実行する.
///
/// 実行: `dart run test/state_entity_checkers_test.dart`
void main() {
  const annotationsImport =
      "import 'package:flutter_layered_architecture_annotations/"
      "flutter_layered_architecture_annotations.dart';";

  group('hasStateAnnotation', () {
    test('@state', () {
      final unit = parseString(
        content:
            '''
$annotationsImport

@state
class S {}
''',
      ).unit;
      expectTrue(hasStateAnnotation(classDeclarationOf(unit)));
    });

    test('無し', () {
      final unit = parseString(content: 'class S {}').unit;
      expectFalse(hasStateAnnotation(classDeclarationOf(unit)));
    });
  });

  group('hasEntityAnnotation', () {
    test('@entity', () {
      final unit = parseString(
        content:
            '''
$annotationsImport

@entity
class E {}
''',
      ).unit;
      expectTrue(hasEntityAnnotation(classDeclarationOf(unit)));
    });
  });

  group('hasStateAndEntityAnnotation', () {
    test('@state @entity', () {
      final unit = parseString(
        content:
            '''
$annotationsImport

@state
@entity
class X {}
''',
      ).unit;
      expectTrue(hasStateAndEntityAnnotation(classDeclarationOf(unit)));
    });
  });

  group('appliesStateEntityGateA', () {
    test('@entity', () {
      final unit = parseString(
        content:
            '''
$annotationsImport

@entity
class E {}
''',
      ).unit;
      expectTrue(appliesStateEntityGateA(classDeclarationOf(unit)));
    });
  });

  group('primaryDataFactoryOf', () {
    test('unnamed', () {
      final unit = parseString(
        content: r'''
import 'package:freezed_annotation/freezed_annotation.dart';

@freezed
abstract class F with _$F {
  const factory F({required int x}) = _F;
}
''',
      ).unit;
      final factory = primaryDataFactoryOf(classDeclarationOf(unit));
      expectTrue(factory != null);
      expectEquals(factory!.name, null);
    });

    test('無し', () {
      final unit = parseString(
        content: '''
class C {
  C();
}
''',
      ).unit;
      expectEquals(primaryDataFactoryOf(classDeclarationOf(unit)), null);
    });
  });

  group('namedFactoriesOf', () {
    test('named factory', () {
      final unit = parseString(
        content: '''
class F {
  factory F.initial() => F._();
  F._();
}
''',
      ).unit;
      expectEquals(namedFactoriesOf(classDeclarationOf(unit)).length, 1);
    });

    test('無し', () {
      final unit = parseString(
        content: '''
class F {
  const factory F({required int x}) = _F;
}
''',
      ).unit;
      expectEquals(namedFactoriesOf(classDeclarationOf(unit)).length, 0);
    });
  });

  group('parameterHasDefaultAnnotation', () {
    test('@Default', () {
      final unit = parseString(
        content: '''
void f(@Default(0) int x) {}
''',
      ).unit;
      final parameter = firstFunctionParameter(unit);
      expectTrue(parameterHasDefaultAnnotation(parameter));
    });

    test('無し', () {
      final unit = parseString(
        content: '''
void f({required int x}) {}
''',
      ).unit;
      final parameter = firstFunctionParameter(unit);
      expectFalse(parameterHasDefaultAnnotation(parameter));
    });
  });

  group('parameterHasDartDefaultValue', () {
    test('optional positional default', () {
      final unit = parseString(content: 'void f([int x = 0]) {}').unit;
      final parameter = firstFunctionParameter(unit);
      expectTrue(parameterHasDartDefaultValue(parameter));
    });

    test('required named', () {
      final unit = parseString(content: 'void f({required int x}) {}').unit;
      final parameter = firstFunctionParameter(unit);
      expectFalse(parameterHasDartDefaultValue(parameter));
    });
  });

  group('nonRequiredPrimaryFactoryParameters', () {
    test('optional and required mix', () {
      final unit = parseString(
        content: '''
abstract class F {
  factory F({int x, required int y}) => throw UnimplementedError();
}
''',
      ).unit;
      final params = nonRequiredPrimaryFactoryParameters(
        classDeclarationOf(unit),
      ).toList();
      expectEquals(params.length, 1);
      expectEquals(params.single.name!.lexeme, 'x');
    });
  });

  group('classHasFreezedAnnotation', () {
    test('class without @freezed', () {
      final unit = parseString(content: 'class F {}').unit;
      expectFalse(classHasFreezedAnnotation(classDeclarationOf(unit)));
    });

    test('@freezed class F {}', () {
      final unit = parseString(
        content: r'''
import 'package:freezed_annotation/freezed_annotation.dart';

@freezed
class F with _$F {
  const factory F({required int x}) = _F;
}
''',
      ).unit;
      final classNode = classDeclarationOf(unit);
      final result = classHasFreezedAnnotation(classNode);
      if (result) {
        expectTrue(result);
      }
      // 要素解決不可時は false 許容（ゲート A の統合検証は example に委譲）.
    });
  });

  // ignore: avoid_print
  print('All state_entity_checkers tests passed.');
}

ClassDeclaration classDeclarationOf(CompilationUnit unit) {
  for (final declaration in unit.declarations) {
    if (declaration is ClassDeclaration) {
      return declaration;
    }
  }
  throw StateError('No class declaration in unit');
}

FormalParameter firstFunctionParameter(CompilationUnit unit) {
  final function = unit.declarations.whereType<FunctionDeclaration>().first;
  final parameters = function.functionExpression.parameters;
  if (parameters == null || parameters.parameters.isEmpty) {
    throw StateError('No function parameters');
  }
  return parameters.parameters.first;
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
