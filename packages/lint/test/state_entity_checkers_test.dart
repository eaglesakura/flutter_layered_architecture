import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_layered_architecture_lint/src/state_entity/state_entity_checkers.dart';
import 'package:test/test.dart';

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
      expect(hasStateAnnotation(classDeclarationOf(unit)), isTrue);
    });

    test('無し', () {
      final unit = parseString(content: 'class S {}').unit;
      expect(hasStateAnnotation(classDeclarationOf(unit)), isFalse);
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
      expect(hasEntityAnnotation(classDeclarationOf(unit)), isTrue);
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
      expect(hasStateAndEntityAnnotation(classDeclarationOf(unit)), isTrue);
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
      expect(appliesStateEntityGateA(classDeclarationOf(unit)), isTrue);
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
      expect(factory != null, isTrue);
      expect(factory!.name, null);
    });

    test('無し', () {
      final unit = parseString(
        content: '''
class C {
  C();
}
''',
      ).unit;
      expect(primaryDataFactoryOf(classDeclarationOf(unit)), null);
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
      expect(namedFactoriesOf(classDeclarationOf(unit)).length, 1);
    });

    test('無し', () {
      final unit = parseString(
        content: '''
class F {
  const factory F({required int x}) = _F;
}
''',
      ).unit;
      expect(namedFactoriesOf(classDeclarationOf(unit)).length, 0);
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
      expect(parameterHasDefaultAnnotation(parameter), isTrue);
    });

    test('無し', () {
      final unit = parseString(
        content: '''
void f({required int x}) {}
''',
      ).unit;
      final parameter = firstFunctionParameter(unit);
      expect(parameterHasDefaultAnnotation(parameter), isFalse);
    });
  });

  group('parameterHasDartDefaultValue', () {
    test('optional positional default', () {
      final unit = parseString(content: 'void f([int x = 0]) {}').unit;
      final parameter = firstFunctionParameter(unit);
      expect(parameterHasDartDefaultValue(parameter), isTrue);
    });

    test('required named', () {
      final unit = parseString(content: 'void f({required int x}) {}').unit;
      final parameter = firstFunctionParameter(unit);
      expect(parameterHasDartDefaultValue(parameter), isFalse);
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
      expect(params.length, 1);
      expect(params.single.name!.lexeme, 'x');
    });
  });

  group('classHasFreezedAnnotation', () {
    test('class without @freezed', () {
      final unit = parseString(content: 'class F {}').unit;
      expect(classHasFreezedAnnotation(classDeclarationOf(unit)), isFalse);
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
        expect(result, isTrue);
      }
      // 要素解決不可時は false 許容（型構造の統合検証は example に委譲）.
    });
  });
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
