// checker 用の複数 @internal API を同一ファイルにまとめる.
// ignore_for_file: flutter_layered_architecture_lint/one_public_type_per_file, flutter_layered_architecture_lint/public_type_file_name

import 'package:flutter_layered_architecture_lint/src/architecture_layer/architecture_layer_checkers.dart';
import 'package:meta/meta.dart';

/// Unit Test 専用 package 名か（pubspec [packageName] の `endsWith('_test')`）.
///
/// Example:
/// ```dart
/// isUnitTestPackageName('usecase_todo_test'); // true
/// isUnitTestPackageName('usecase_todo_testing'); // false
/// ```
@internal
bool isUnitTestPackageName(String packageName) => packageName.endsWith('_test');

/// レイヤー／責務内テストサポート名か（`endsWith('_testing')`）.
///
/// 規約・単体テスト用。Rule は呼ばない.
///
/// Example:
/// ```dart
/// isLayerTestingSupportPackageName('domain_account_testing'); // true
/// ```
@internal
bool isLayerTestingSupportPackageName(String packageName) =>
    packageName.endsWith('_testing');

/// 横断・共有テストサポート名か（`startsWith('testing_')`）.
///
/// 規約・単体テスト用。Rule は呼ばない.
///
/// Example:
/// ```dart
/// isSharedTestingSupportPackageName('testing_core'); // true
/// ```
@internal
bool isSharedTestingSupportPackageName(String packageName) =>
    packageName.startsWith('testing_');

/// 依存先が Unit Test 用 package（単一 path_prefix 所属かつ `*_test`）なら true.
///
/// Example:
/// ```dart
/// isForbiddenUnitTestPackageDependency(
///   definitionDir: '/ws',
///   layers: [domain],
///   dependencyName: 'domain_todo_test',
///   dependencyRootPath: '/ws/example/domain/todo/_test',
/// ); // true when path matches domain path_prefix
/// ```
@internal
bool isForbiddenUnitTestPackageDependency({
  required String definitionDir,
  required List<ArchitectureLayer> layers,
  required String dependencyName,
  required String? dependencyRootPath,
}) {
  if (!isUnitTestPackageName(dependencyName)) {
    return false;
  }
  if (dependencyRootPath == null) {
    return false;
  }
  final depLayers = layersForPackagePath(
    definitionDir: definitionDir,
    layers: layers,
    packageRootPath: dependencyRootPath,
  );
  return depLayers.length == 1;
}
