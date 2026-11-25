// ignore_for_file: flutter_layered_architecture_lint/one_public_type_per_file, flutter_layered_architecture_lint/public_type_file_name

import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

/// package のアーキテクチャ役割（バレル annotation 由来）.
@internal
enum PackageRole {
  /// annotation なし.
  none,

  /// `@injection` のみ.
  injection,

  /// `@implementation` のみ.
  implementation,

  /// 両方（warning 対象）.
  both,
}

/// 単一バレルソースから役割フラグを読む.
///
/// Example:
/// ```dart
/// annotationsFromBarrelSource('@injection\nlibrary;\n');
/// // (hasInjection: true, hasImplementation: false)
/// ```
@internal
({bool hasInjection, bool hasImplementation}) annotationsFromBarrelSource(
  String dartSource,
) {
  final parsed = parseString(content: dartSource, throwIfDiagnostics: false);
  final libraries = parsed.unit.directives.whereType<LibraryDirective>();
  if (libraries.isEmpty) {
    return (hasInjection: false, hasImplementation: false);
  }
  var hasInjection = false;
  var hasImplementation = false;
  for (final library in libraries) {
    for (final annotation in library.metadata) {
      final name = _annotationSimpleName(annotation);
      if (name == 'injection' || name == 'Injection') {
        hasInjection = true;
      } else if (name == 'implementation' || name == 'Implementation') {
        hasImplementation = true;
      }
    }
  }
  return (hasInjection: hasInjection, hasImplementation: hasImplementation);
}

String? _annotationSimpleName(Annotation annotation) {
  final nameNode = annotation.name;
  if (nameNode is SimpleIdentifier) {
    return nameNode.name;
  }
  if (nameNode is PrefixedIdentifier) {
    return nameNode.identifier.name;
  }
  return nameNode.toString();
}

/// バレル（`lib/` 直下かつ `library` あり）から [PackageRole] を判定する.
///
/// 名前ベース判定（URI は見ない）。`lib/src/` は見ない。
///
/// Example:
/// ```dart
/// detectPackageRole(packageRootPath: '/ws/example/data/injection', readTextFile: readTextFile);
/// ```
@internal
PackageRole detectPackageRole({
  required String packageRootPath,
  required String? Function(String path) readTextFile,
}) {
  final libDir = Directory(p.join(packageRootPath, 'lib'));
  if (!libDir.existsSync()) {
    return PackageRole.none;
  }
  var hasInjection = false;
  var hasImplementation = false;
  for (final entity in libDir.listSync(followLinks: false)) {
    if (entity is! File) {
      continue;
    }
    if (p.extension(entity.path) != '.dart') {
      continue;
    }
    final text = readTextFile(entity.path);
    if (text == null) {
      continue;
    }
    final flags = annotationsFromBarrelSource(text);
    hasInjection = hasInjection || flags.hasInjection;
    hasImplementation = hasImplementation || flags.hasImplementation;
  }
  if (hasInjection && hasImplementation) {
    return PackageRole.both;
  }
  if (hasInjection) {
    return PackageRole.injection;
  }
  if (hasImplementation) {
    return PackageRole.implementation;
  }
  return PackageRole.none;
}

/// `@implementation`（および `both`）依存が許可されるか.
///
/// * 依存先が `implementation` / `both` 以外 → 常に true（本ルール対象外）
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
      dependencyRole == PackageRole.implementation ||
      dependencyRole == PackageRole.both;
  if (!dependencyIsImplementation) {
    return true;
  }
  if (selfRole != PackageRole.injection) {
    return false;
  }
  return selfLayerName == dependencyLayerName;
}
