import 'package:analyzer/dart/ast/ast.dart';
import 'package:meta/meta.dart';

/// 検査対象とする Provider 系のルート識別子名.
///
/// element 解決は行わず、AST 上の単純名で判定する.
@internal
const Set<String> kProviderLikeRootNames = {
  'Provider',
  'FutureProvider',
  'StreamProvider',
  'StateNotifierProvider',
  'NotifierProvider',
  'AsyncNotifierProvider',
  'StreamNotifierProvider',
  'StateStreamProvider',
};

/// [expression] が provider-like 呼び出しか（ルート名が [kProviderLikeRootNames]）.
///
/// [MethodInvocation] と [InstanceCreationExpression] の両方を対象とする.
///
/// Example:
/// ```dart
/// isProviderLikeExpression(parseInit('Provider<int>((ref) => 1)')); // true
/// isProviderLikeExpression(parseInit('const Provider((ref) => 1)')); // true
/// ```
@internal
bool isProviderLikeExpression(Expression? expression) {
  final root = providerRootNameFromExpression(expression);
  return root != null && kProviderLikeRootNames.contains(root);
}

/// provider-like 呼び出しからルート単純名を取る.
///
/// [MethodInvocation] / [InstanceCreationExpression] を扱う.
/// 非対応形は null.
///
/// Example:
/// ```dart
/// providerRootNameFromExpression(parseInit('Provider<T>((ref) => 1)')); // 'Provider'
/// providerRootNameFromExpression(parseInit('const Provider((ref) => 1)')); // 'Provider'
/// ```
@internal
String? providerRootNameFromExpression(Expression? expression) {
  final unwrapped = _unwrapParentheses(expression);
  if (unwrapped is MethodInvocation) {
    return providerRootName(unwrapped);
  }
  if (unwrapped is InstanceCreationExpression) {
    return unwrapped.constructorName.type.name.lexeme;
  }
  return null;
}

/// [MethodInvocation] チェーンのルート単純名.
///
/// target が [PropertyAccess] / 括弧付きの場合も左端まで辿る.
///
/// Example:
/// ```dart
/// providerRootName(invocation); // 'Provider' / 'StateStreamProvider'
/// ```
@internal
String? providerRootName(MethodInvocation invocation) {
  final target = invocation.target;
  if (target == null) {
    return invocation.methodName.name;
  }
  return _rootNameFromTargetExpression(target);
}

/// 呼び出しが `.stateBy(...)` で終わるか（create コールバック無し扱い）.
///
/// [InstanceCreationExpression] は常に false.
///
/// Example:
/// ```dart
/// endsWithStateBy(parseInit('StateStreamProvider.autoDispose.stateBy(a, f)')); // true
/// ```
@internal
bool endsWithStateBy(Expression? expression) {
  final unwrapped = _unwrapParentheses(expression);
  return unwrapped is MethodInvocation &&
      unwrapped.methodName.name == 'stateBy';
}

/// provider-like 呼び出しの [ArgumentList]. 非対応なら null.
///
/// Example:
/// ```dart
/// providerArgumentList(parseInit('Provider((ref) => 1)'));
/// ```
@internal
ArgumentList? providerArgumentList(Expression? expression) {
  final unwrapped = _unwrapParentheses(expression);
  if (unwrapped is MethodInvocation) {
    return unwrapped.argumentList;
  }
  if (unwrapped is InstanceCreationExpression) {
    return unwrapped.argumentList;
  }
  return null;
}

/// provider-like 呼び出しから create コールバック（最初の位置 FunctionExpression）を取る.
///
/// `.stateBy` 終わり、または該当引数が無ければ null（ルール B/C スキップ）.
///
/// Example:
/// ```dart
/// createCallbackOfProviderLike(parseInit('Provider((ref) => 1)')); // FunctionExpression
/// createCallbackOfProviderLike(parseInit('StateStreamProvider.autoDispose.stateBy(a, f)')); // null
/// ```
@internal
FunctionExpression? createCallbackOfProviderLike(Expression? expression) {
  if (endsWithStateBy(expression)) {
    return null;
  }
  final argumentList = providerArgumentList(expression);
  if (argumentList == null) {
    return null;
  }
  for (final argument in argumentList.arguments) {
    if (argument is NamedArgument) {
      continue;
    }
    final value = argument.argumentExpression;
    if (value is FunctionExpression) {
      return value;
    }
  }
  return null;
}

/// `dependencies:` 名前付き引数のリスト要素を、字面（`toSource().trim()`）の一覧で返す.
///
/// 引数欠落・非 ListLiteral・非 Expression 要素は空扱い（ルール C は欠落とみなす）.
///
/// Example:
/// ```dart
/// dependenciesLiteralsOf(
///   parseInit('Provider((ref) => 1, dependencies: [Other.provider])'),
/// ); // ['Other.provider']
/// ```
@internal
List<String> dependenciesLiteralsOf(Expression? expression) {
  final argumentList = providerArgumentList(expression);
  if (argumentList == null) {
    return const [];
  }
  for (final argument in argumentList.arguments) {
    if (argument is! NamedArgument) {
      continue;
    }
    if (argument.name.lexeme != 'dependencies') {
      continue;
    }
    final list = argument.argumentExpression;
    if (list is! ListLiteral) {
      return const [];
    }
    final result = <String>[];
    for (final element in list.elements) {
      if (element is Expression) {
        result.add(element.toSource().trim());
      }
    }
    return result;
  }
  return const [];
}

/// create コールバック直下の `ref.<method>(...)` 呼び出しを列挙する.
///
/// ネストした [FunctionExpression] 内は除外する。引数式の中（例: コンストラクタ引数）は含む.
///
/// Example:
/// ```dart
/// directRefInvocations(create, 'watch');
/// directRefInvocations(create, 'read');
/// ```
@internal
Iterable<MethodInvocation> directRefInvocations(
  FunctionExpression create,
  String method,
) sync* {
  for (final node in _descendants(create.body)) {
    if (node is! MethodInvocation) {
      continue;
    }
    if (node.methodName.name != method) {
      continue;
    }
    final target = node.target;
    if (target is! SimpleIdentifier || target.name != 'ref') {
      continue;
    }
    if (!_isUnderCreateNotNestedFunction(node, create)) {
      continue;
    }
    yield node;
  }
}

/// [watchInvocation]（`ref.watch(X)`）の第1位置引数の字面. 無ければ null.
///
/// Example:
/// ```dart
/// refWatchArgumentLiteral(watchNode); // 'TodoRepository.provider'
/// ```
@internal
String? refWatchArgumentLiteral(MethodInvocation watchInvocation) {
  final arguments = watchInvocation.argumentList.arguments;
  if (arguments.isEmpty) {
    return null;
  }
  return arguments.first.argumentExpression.toSource().trim();
}

/// ルール C: [watchInvocation] が [dependenciesLiterals] に字面一致で含まれるか.
///
/// Example:
/// ```dart
/// isWatchListedInDependencies(watch, ['TodoRepository.provider']); // true
/// ```
@internal
bool isWatchListedInDependencies(
  MethodInvocation watchInvocation,
  List<String> dependenciesLiterals,
) {
  final literal = refWatchArgumentLiteral(watchInvocation);
  if (literal == null) {
    return true;
  }
  return dependenciesLiterals.contains(literal);
}

/// FieldDeclaration の宿主型ノード（`field.parent?.parent`）.
///
/// analyzer 14 では Field は ClassBody 等の子、その親が ClassDeclaration 等.
///
/// Example:
/// ```dart
/// fieldHostDeclaration(field); // ClassDeclaration / MixinDeclaration / ...
/// ```
@internal
AstNode? fieldHostDeclaration(FieldDeclaration field) {
  return field.parent?.parent;
}

/// ルール A の適合宿主か（[ClassDeclaration] のみ. mixin class 含む）.
///
/// Example:
/// ```dart
/// isProviderHostCompatible(classNode); // true
/// isProviderHostCompatible(mixinNode); // false
/// ```
@internal
bool isProviderHostCompatible(AstNode? host) => host is ClassDeclaration;

/// class 系上の `static final` フィールドか.
///
/// Example:
/// ```dart
/// isStaticFinalField(field); // static final provider = ...
/// ```
@internal
bool isStaticFinalField(FieldDeclaration field) {
  return field.isStatic && field.fields.isFinal;
}

/// ルール A: トップレベル変数が provider-like なら違反（報告対象の VariableDeclaration を返す）.
///
/// Example:
/// ```dart
/// providerLikeVariablesInTopLevel(topLevelDecl);
/// ```
@internal
Iterable<VariableDeclaration> providerLikeVariablesInTopLevel(
  TopLevelVariableDeclaration declaration,
) sync* {
  for (final variable in declaration.variables.variables) {
    if (isProviderLikeExpression(variable.initializer)) {
      yield variable;
    }
  }
}

/// ルール A: フィールドが provider-like かつ（宿主非適合 or 非 static final）なら違反変数を返す.
///
/// Example:
/// ```dart
/// providerLikeViolatingFieldVariables(field);
/// ```
@internal
Iterable<VariableDeclaration> providerLikeViolatingFieldVariables(
  FieldDeclaration field,
) sync* {
  final host = fieldHostDeclaration(field);
  final hostOk = isProviderHostCompatible(host);
  final staticFinalOk = isStaticFinalField(field);
  for (final variable in field.fields.variables) {
    if (!isProviderLikeExpression(variable.initializer)) {
      continue;
    }
    if (!hostOk || !staticFinalOk) {
      yield variable;
    }
  }
}

/// 括弧を外した式を返す.
///
/// [expression] が null なら null.
Expression? _unwrapParentheses(Expression? expression) {
  var current = expression;
  while (current is ParenthesizedExpression) {
    current = current.expression;
  }
  return current;
}

/// 呼び出し target 式からルート単純名を辿る.
///
/// [SimpleIdentifier] / [PrefixedIdentifier] / [PropertyAccess] /
/// [MethodInvocation] / 括弧を扱う.
String? _rootNameFromTargetExpression(Expression target) {
  final unwrapped = _unwrapParentheses(target);
  if (unwrapped is SimpleIdentifier) {
    return unwrapped.name;
  }
  if (unwrapped is PrefixedIdentifier) {
    return unwrapped.prefix.name;
  }
  if (unwrapped is PropertyAccess) {
    final inner = unwrapped.target;
    if (inner != null) {
      final nested = _rootNameFromTargetExpression(inner);
      if (nested != null) {
        return nested;
      }
    }
    return unwrapped.propertyName.name;
  }
  if (unwrapped is MethodInvocation) {
    return providerRootName(unwrapped);
  }
  return null;
}

/// [node] が [create] 配下にあり、途中の別 FunctionExpression に入っていないか.
bool _isUnderCreateNotNestedFunction(
  AstNode node,
  FunctionExpression create,
) {
  AstNode? current = node.parent;
  while (current != null) {
    if (identical(current, create)) {
      return true;
    }
    if (current is FunctionExpression && !identical(current, create)) {
      return false;
    }
    current = current.parent;
  }
  return false;
}

/// [root] 配下の全 AST 子孫を深さ優先で列挙する.
Iterable<AstNode> _descendants(AstNode root) sync* {
  for (final child in root.childEntities) {
    if (child is AstNode) {
      yield child;
      yield* _descendants(child);
    }
  }
}
