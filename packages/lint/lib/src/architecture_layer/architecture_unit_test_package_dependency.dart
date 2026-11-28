import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_layer/architecture_layer_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_layer/architecture_unit_test_package_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

/// Unit Test 用 package（`*_test`）への依存を禁止する Lint（WARNING）.
///
/// 依存元が path_prefix 所属のとき、`dependencies` / `dev_dependencies` の
/// 直接依存先が in-layer かつ `endsWith('_test')` なら警告する（leaf 制約）.
/// 定義不在・アーキテクチャ外はスキップ（`architecture_layer_dependency` 担当）.
///
/// Example:
/// ```dart
/// // domain_todo が usecase_todo_test に直接依存
/// // → architecture_unit_test_package_dependency
/// ```
@internal
final class ArchitectureUnitTestPackageDependency extends AnalysisRule {
  /// [ArchitectureUnitTestPackageDependency] の診断コード（メッセージは `{0}`）.
  static const LintCode code = LintCode(
    'architecture_unit_test_package_dependency',
    '{0}',
    severity: architectureViolationSeverity,
  );

  /// [ArchitectureUnitTestPackageDependency] ルールを生成する.
  ArchitectureUnitTestPackageDependency()
    : super(
        name: 'architecture_unit_test_package_dependency',
        description:
            'Warns when an in-layer package depends on a unit-test '
            'package (*_test) via dependencies or dev_dependencies.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addCompilationUnit(this, _Visitor(this, context));
  }
}

/// CompilationUnit ごとに package 単位で Unit Test package 依存を 1 回検査する.
final class _Visitor extends SimpleAstVisitor<void> {
  /// 正規化 package root → 二重実行防止.
  static final Set<String> _reportedPackageRoots = {};

  final ArchitectureUnitTestPackageDependency rule;

  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final filePath = context.currentUnit?.file.path;
    if (filePath == null || filePath.isEmpty) {
      return;
    }
    final packageRoot = findPackageRoot(filePath);
    if (packageRoot == null) {
      return;
    }
    if (_reportedPackageRoots.contains(packageRoot)) {
      return;
    }
    _reportedPackageRoots.add(packageRoot);

    // 定義まわりの報告は architecture_layer_dependency 担当.
    final definitionPath = findLayeredArchitectureYaml(packageRoot);
    if (definitionPath == null) {
      return;
    }
    final definitionYamlText = readTextFile(definitionPath);
    if (definitionYamlText == null) {
      return;
    }
    final parseResult = parseLayerArchitectureYaml(definitionYamlText);
    if (parseResult is LayerArchitectureParseFailure) {
      return;
    }
    final definition = parseResult as LayerArchitectureDefinition;
    final definitionDir = normalizePathForCompare(p.dirname(definitionPath));

    final selfLayers = layersForPackagePath(
      definitionDir: definitionDir,
      layers: definition.layers,
      packageRootPath: packageRoot,
    );
    // 依存元は in-layer かつ単一所属のみ検査.
    if (selfLayers.isEmpty || selfLayers.length > 1) {
      return;
    }

    final packageConfigPath = findPackageConfigJson(packageRoot);
    if (packageConfigPath == null) {
      return;
    }
    final packageConfigText = readTextFile(packageConfigPath);
    if (packageConfigText == null) {
      return;
    }
    final pubspecText = readTextFile(p.join(packageRoot, 'pubspec.yaml'));
    if (pubspecText == null) {
      return;
    }
    final direct = parseDirectDependencyNames(pubspecText);
    final dependencyNames = <String>{
      ...direct.dependencies,
      ...direct.devDependencies,
    };
    final packageRoots = packageRootsFromPackageConfig(
      packageConfigJsonText: packageConfigText,
      packageConfigFileDirectory: p.dirname(packageConfigPath),
    );

    for (final dependencyName in dependencyNames) {
      final dependencyRoot = packageRoots[dependencyName];
      if (!isForbiddenUnitTestPackageDependency(
        definitionDir: definitionDir,
        layers: definition.layers,
        dependencyName: dependencyName,
        dependencyRootPath: dependencyRoot,
      )) {
        continue;
      }
      final message =
          "Dependency '$dependencyName' is a unit-test package (*_test) and "
          'must remain a leaf; remove it from dependencies/dev_dependencies.';
      rule.reportAtNode(node, arguments: [message]);
    }
  }
}
