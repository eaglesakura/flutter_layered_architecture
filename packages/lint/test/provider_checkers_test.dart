import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_layered_architecture_lint/src/provider/provider_checkers.dart';
import 'package:test/test.dart';

void main() {
  group('isProviderLikeExpression / providerRootName', () {
    test('Provider', () {
      final init = topLevelInitializer('final x = Provider((ref) => 1);');
      expect(isProviderLikeExpression(init), isTrue);
      expect(providerRootNameFromExpression(init), 'Provider');
      expect(providerRootName(init as MethodInvocation), 'Provider');
    });

    test('Provider 型引数付き（MethodInvocation）', () {
      final init = topLevelInitializer(
        'final x = Provider<TodoRepository>((ref) => throw 0);',
      );
      expect(init, isA<MethodInvocation>());
      expect(isProviderLikeExpression(init), isTrue);
      expect(providerRootNameFromExpression(init), 'Provider');
      expect(createCallbackOfProviderLike(init), isNotNull);
    });

    test('const Provider（InstanceCreationExpression）', () {
      final init = topLevelInitializer(
        'final x = const Provider((ref) => 1);',
      );
      expect(init, isA<InstanceCreationExpression>());
      expect(isProviderLikeExpression(init), isTrue);
      expect(providerRootNameFromExpression(init), 'Provider');
      expect(createCallbackOfProviderLike(init), isNotNull);
    });

    test('const Provider 型引数付き（InstanceCreationExpression）', () {
      final init = topLevelInitializer(
        'final x = const Provider<int>((ref) => 1);',
      );
      expect(init, isA<InstanceCreationExpression>());
      expect(isProviderLikeExpression(init), isTrue);
      expect(dependenciesLiteralsOf(init), isEmpty);
    });

    test('Provider.autoDispose 型引数付き', () {
      final init = topLevelInitializer(
        'final x = Provider.autoDispose<int>((ref) => 1);',
      );
      expect(isProviderLikeExpression(init), isTrue);
      expect(providerRootNameFromExpression(init), 'Provider');
    });

    test('StateStreamProvider.autoDispose.stateBy', () {
      final init = topLevelInitializer(
        'final x = StateStreamProvider.autoDispose.stateBy(a, (vm) => vm.e);',
      );
      expect(isProviderLikeExpression(init), isTrue);
      expect(providerRootNameFromExpression(init), 'StateStreamProvider');
      expect(endsWithStateBy(init), isTrue);
    });

    test('非 provider', () {
      final init = topLevelInitializer('final x = Object();');
      expect(isProviderLikeExpression(init), isFalse);
    });

    test('ルート名 table-driven', () {
      const roots = [
        'Provider',
        'FutureProvider',
        'StreamProvider',
        'StateNotifierProvider',
        'NotifierProvider',
        'AsyncNotifierProvider',
        'StreamNotifierProvider',
        'StateStreamProvider',
      ];
      for (final root in roots) {
        final init = topLevelInitializer('final x = $root((ref) => 1);');
        expect(
          isProviderLikeExpression(init),
          isTrue,
          reason: root,
        );
        expect(providerRootNameFromExpression(init), root, reason: root);
      }
    });
  });

  group('createCallbackOfProviderLike', () {
    test('Provider create あり', () {
      final init = topLevelInitializer('final x = Provider((ref) => 1);');
      expect(createCallbackOfProviderLike(init), isNotNull);
    });

    test('stateBy は create 無し', () {
      final init = topLevelInitializer(
        'final x = StateStreamProvider.autoDispose.stateBy(a, (vm) => vm.e);',
      );
      expect(createCallbackOfProviderLike(init), isNull);
    });
  });

  group('dependenciesLiteralsOf', () {
    test('一覧', () {
      final init = topLevelInitializer(
        'final x = Provider((ref) => 1, dependencies: [Other.provider, Extra.provider]);',
      );
      expect(dependenciesLiteralsOf(init), [
        'Other.provider',
        'Extra.provider',
      ]);
    });

    test('型引数付き + dependencies', () {
      final init = topLevelInitializer(
        'final x = Provider<Impl>((ref) => Impl(ref.watch(Other.provider)), '
        'dependencies: [Other.provider]);',
      );
      expect(dependenciesLiteralsOf(init), ['Other.provider']);
    });

    test('欠落は空', () {
      final init = topLevelInitializer('final x = Provider((ref) => 1);');
      expect(dependenciesLiteralsOf(init), isEmpty);
    });

    test('空リスト', () {
      final init = topLevelInitializer(
        'final x = Provider((ref) => 1, dependencies: []);',
      );
      expect(dependenciesLiteralsOf(init), isEmpty);
    });
  });

  group('directRefInvocations', () {
    test('直下 watch / read を検出、ネスト関数は除外', () {
      final init = topLevelInitializer('''
final x = Provider((ref) {
  final a = ref.watch(Other.provider);
  final b = ref.read(Other.provider);
  void nested() {
    ref.read(Nested.provider);
  }
  return 1;
});
''');
      final create = createCallbackOfProviderLike(init)!;
      expect(directRefInvocations(create, 'watch').length, 1);
      expect(directRefInvocations(create, 'read').length, 1);
    });

    test('式本体のコンストラクタ引数内 watch も直下', () {
      final init = topLevelInitializer(
        'final x = Provider((ref) => Impl(ref.watch(Other.provider)));',
      );
      final create = createCallbackOfProviderLike(init)!;
      final watches = directRefInvocations(create, 'watch').toList();
      expect(watches.length, 1);
      expect(refWatchArgumentLiteral(watches.single), 'Other.provider');
    });
  });

  group('isWatchListedInDependencies', () {
    test('一致', () {
      final init = topLevelInitializer('''
final x = Provider(
  (ref) => Impl(ref.watch(Other.provider)),
  dependencies: [Other.provider],
);
''');
      final create = createCallbackOfProviderLike(init)!;
      final watch = directRefInvocations(create, 'watch').single;
      expect(
        isWatchListedInDependencies(watch, dependenciesLiteralsOf(init)),
        isTrue,
      );
    });

    test('欠落', () {
      final init = topLevelInitializer('''
final x = Provider(
  (ref) => Impl(ref.watch(Other.provider)),
  dependencies: [],
);
''');
      final create = createCallbackOfProviderLike(init)!;
      final watch = directRefInvocations(create, 'watch').single;
      expect(
        isWatchListedInDependencies(watch, dependenciesLiteralsOf(init)),
        isFalse,
      );
    });

    test('余分は許容（一致分は true）', () {
      final init = topLevelInitializer('''
final x = Provider(
  (ref) => Impl(ref.watch(Other.provider)),
  dependencies: [Other.provider, Extra.provider],
);
''');
      final create = createCallbackOfProviderLike(init)!;
      final watch = directRefInvocations(create, 'watch').single;
      expect(
        isWatchListedInDependencies(watch, dependenciesLiteralsOf(init)),
        isTrue,
      );
    });

    test('複数 watch の部分欠落', () {
      final init = topLevelInitializer('''
final x = Provider((ref) {
  final a = ref.watch(A.provider);
  final b = ref.watch(B.provider);
  return Impl(a, b);
}, dependencies: [A.provider]);
''');
      final create = createCallbackOfProviderLike(init)!;
      final deps = dependenciesLiteralsOf(init);
      final watches = directRefInvocations(create, 'watch').toList();
      expect(watches.length, 2);
      expect(isWatchListedInDependencies(watches[0], deps), isTrue);
      expect(isWatchListedInDependencies(watches[1], deps), isFalse);
    });
  });

  group('ルール A helpers', () {
    test('トップレベル provider-like', () {
      final unit = parseString(
        content: 'final x = Provider((ref) => 1);',
      ).unit;
      final top = unit.declarations
          .whereType<TopLevelVariableDeclaration>()
          .single;
      expect(providerLikeVariablesInTopLevel(top).length, 1);
    });

    test('トップレベル StateStreamProvider', () {
      final unit = parseString(
        content: 'final x = StateStreamProvider.autoDispose.stateBy(a, (vm) => vm.e);',
      ).unit;
      final top = unit.declarations
          .whereType<TopLevelVariableDeclaration>()
          .single;
      expect(providerLikeVariablesInTopLevel(top).length, 1);
    });

    test('class static final はフィールド違反なし', () {
      final field = fieldOf('''
class C {
  static final provider = Provider((ref) => 1);
}
''');
      expect(isProviderHostCompatible(fieldHostDeclaration(field)), isTrue);
      expect(isStaticFinalField(field), isTrue);
      expect(providerLikeViolatingFieldVariables(field), isEmpty);
    });

    test('instance フィールドは違反', () {
      final field = fieldOf('''
class C {
  final provider = Provider((ref) => 1);
}
''');
      expect(providerLikeViolatingFieldVariables(field).length, 1);
    });

    test('static だが final でないフィールドは違反', () {
      final field = fieldOf('''
class C {
  static var provider = Provider((ref) => 1);
}
''');
      expect(isStaticFinalField(field), isFalse);
      expect(providerLikeViolatingFieldVariables(field).length, 1);
    });

    test('mixin 上は宿主非適合で違反', () {
      final field = fieldOf('''
mixin M {
  static final provider = Provider((ref) => 1);
}
''');
      expect(isProviderHostCompatible(fieldHostDeclaration(field)), isFalse);
      expect(providerLikeViolatingFieldVariables(field).length, 1);
    });

    test('enum 上は宿主非適合で違反', () {
      final field = fieldOf('''
enum E {
  a;
  static final provider = Provider((ref) => 1);
}
''');
      expect(isProviderHostCompatible(fieldHostDeclaration(field)), isFalse);
      expect(providerLikeViolatingFieldVariables(field).length, 1);
    });

    test('abstract interface class は適合宿主', () {
      final field = fieldOf('''
abstract interface class TodoRepository {
  static final provider = Provider((ref) => throw UnimplementedError());
}
''');
      expect(isProviderHostCompatible(fieldHostDeclaration(field)), isTrue);
      expect(providerLikeViolatingFieldVariables(field), isEmpty);
    });
  });
}

/// トップレベル変数の初期化子式を返す.
Expression topLevelInitializer(String content) {
  final unit = parseString(content: content).unit;
  final top = unit.declarations.whereType<TopLevelVariableDeclaration>().single;
  return top.variables.variables.single.initializer!;
}

/// ソース先頭の FieldDeclaration を返す.
FieldDeclaration fieldOf(String content) {
  final unit = parseString(content: content).unit;
  for (final declaration in unit.declarations) {
    final members = switch (declaration) {
      ClassDeclaration(:final body) => body.members,
      MixinDeclaration(:final body) => body.members,
      EnumDeclaration(:final body) => body.members,
      ExtensionDeclaration(:final body) => body.members,
      ExtensionTypeDeclaration(:final body) => body.members,
      _ => null,
    };
    if (members == null) {
      continue;
    }
    for (final member in members) {
      if (member is FieldDeclaration) {
        return member;
      }
    }
  }
  throw StateError('No FieldDeclaration');
}
