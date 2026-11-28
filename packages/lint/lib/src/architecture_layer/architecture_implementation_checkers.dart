// ignore_for_file: flutter_layered_architecture_lint/one_public_type_per_file, flutter_layered_architecture_lint/public_type_file_name

import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart';

/// package のアーキテクチャ役割（pubspec `name` のサフィックス由来）.
@internal
enum PackageRole {
  /// サフィックスなし.
  none,

  /// `_injection` で終わる package.
  injection,

  /// `_impl` で終わる package.
  implementation,
}

/// pubspec `name` から役割を返す. null/空 → none.
///
/// `_injection` を先に判定（`foo_impl_injection` → injection）.
///
/// Example:
/// ```dart
/// packageRoleFromPackageName('data_injection'); // PackageRole.injection
/// ```
@internal
PackageRole packageRoleFromPackageName(String? packageName) {
  if (packageName == null || packageName.isEmpty) {
    return PackageRole.none;
  }
  if (packageName.endsWith('_injection')) {
    return PackageRole.injection;
  }
  if (packageName.endsWith('_impl')) {
    return PackageRole.implementation;
  }
  return PackageRole.none;
}

/// `_impl` package への依存が許可されるか.
///
/// * 依存先が `implementation` 以外 → 常に true（本ルール対象外）
/// * それ以外で self が `injection` 以外 → false
/// * 同一レイヤー名なら true、異なれば false
///
/// Example:
/// ```dart
/// isImplementationDependencyAllowed(
///   selfRole: PackageRole.injection,
///   selfLayerName: 'data',
///   dependencyRole: PackageRole.implementation,
///   dependencyLayerName: 'data',
/// ); // true
/// ```
@internal
bool isImplementationDependencyAllowed({
  required PackageRole selfRole,
  required String selfLayerName,
  required PackageRole dependencyRole,
  required String dependencyLayerName,
}) {
  final dependencyIsImplementation =
      dependencyRole == PackageRole.implementation;
  if (!dependencyIsImplementation) {
    return true;
  }
  if (selfRole != PackageRole.injection) {
    return false;
  }
  return selfLayerName == dependencyLayerName;
}

@internal
sealed class ArchitectureImplementationIgnoreParseResult {}

/// ignore パース成功. [entries] は記載順（trim しない。重複はそのまま）.
@internal
final class ArchitectureImplementationIgnoreParseSuccess
    extends ArchitectureImplementationIgnoreParseResult {
  final List<String> entries;

  ArchitectureImplementationIgnoreParseSuccess(this.entries);
}

/// ignore 形式不正.
@internal
final class ArchitectureImplementationIgnoreParseFailure
    extends ArchitectureImplementationIgnoreParseResult {
  final String message;

  ArchitectureImplementationIgnoreParseFailure(this.message);
}

/// yaml 全文から `rules.architecture_implementation_dependency.ignore` を読む.
///
/// * 辿り方は layer ignore に倣うが、不正時は空成功にせず Failure.
/// * 要素不正はスキップせず全体 Failure（以降の要素は見ない）.
/// * 文字列は trim しない.
///
/// Example:
/// ```dart
/// parseArchitectureImplementationDependencyIgnore('rules:\n  architecture_implementation_dependency:\n    ignore:\n      - a\n');
/// ```
@internal
ArchitectureImplementationIgnoreParseResult
parseArchitectureImplementationDependencyIgnore(String yamlText) {
  final Object? document;
  try {
    document = loadYaml(yamlText);
  } on YamlException catch (error) {
    return ArchitectureImplementationIgnoreParseFailure(
      'Invalid YAML: ${error.message}',
    );
  }
  if (document is! YamlMap) {
    return ArchitectureImplementationIgnoreParseFailure(
      'Top-level YAML must be a map',
    );
  }

  final rules = document['rules'];
  if (rules == null) {
    return ArchitectureImplementationIgnoreParseSuccess(const []);
  }
  if (rules is! YamlMap) {
    return ArchitectureImplementationIgnoreParseFailure('rules must be a map');
  }

  final ruleConfig = rules['architecture_implementation_dependency'];
  if (ruleConfig == null) {
    return ArchitectureImplementationIgnoreParseSuccess(const []);
  }
  if (ruleConfig is! YamlMap) {
    return ArchitectureImplementationIgnoreParseFailure(
      'rules.architecture_implementation_dependency must be a map',
    );
  }

  if (!ruleConfig.keys.contains('ignore')) {
    return ArchitectureImplementationIgnoreParseSuccess(const []);
  }

  final ignoreNode = ruleConfig['ignore'];
  if (ignoreNode == null) {
    return ArchitectureImplementationIgnoreParseSuccess(const []);
  }
  if (ignoreNode is! YamlList) {
    return ArchitectureImplementationIgnoreParseFailure(
      'rules.architecture_implementation_dependency.ignore must be a list',
    );
  }

  final entries = <String>[];
  for (final item in ignoreNode) {
    if (item is! String) {
      return ArchitectureImplementationIgnoreParseFailure(
        'ignore entries must be non-empty strings',
      );
    }
    if (item.isEmpty) {
      return ArchitectureImplementationIgnoreParseFailure(
        'ignore entries must be non-empty strings',
      );
    }
    entries.add(item);
  }
  return ArchitectureImplementationIgnoreParseSuccess(entries);
}
