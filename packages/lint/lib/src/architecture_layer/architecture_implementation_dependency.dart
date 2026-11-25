import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_layer/architecture_implementation_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_layer/architecture_layer_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

/// `@implementation` package への依存を同一レイヤー `@injection` に限定する Lint（WARNING）.
///
/// アーキテクチャ外・定義不在はスキップ（`architecture_layer_dependency` 担当）.
///
/// Example:
/// ```dart
/// // example_app が data_repository_todo_impl に直接依存 → architecture_implementation_dependency
/// ```
@internal
final class ArchitectureImplementationDependency extends AnalysisRule {
  static const LintCode code = LintCode(
    'architecture_implementation_dependency',
    '{0}',
    severity: architectureViolationSeverity,
  );

  ArchitectureImplementationDependency()
    : super(
        name: 'architecture_implementation_dependency',
        description:
            'Warns when a non-injection or cross-layer package depends on '
            '@implementation packages.',
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

final class _Visitor extends SimpleAstVisitor<void> {
  static final Set<String> _reportedPackageRoots = {};

  final ArchitectureImplementationDependency rule;
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
    if (selfLayers.isEmpty || selfLayers.length > 1) {
      return;
    }
    final selfLayer = selfLayers.single;

    final selfRole = detectPackageRole(
      packageRootPath: packageRoot,
      readTextFile: readTextFile,
    );
    if (selfRole == PackageRole.both) {
      rule.reportAtNode(
        node,
        arguments: [
          'Package declares both @injection and @implementation on barrel '
              'libraries; keep exactly one role.',
        ],
      );
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
      if (dependencyRoot == null) {
        continue;
      }
      final dependencyLayers = layersForPackagePath(
        definitionDir: definitionDir,
        layers: definition.layers,
        packageRootPath: dependencyRoot,
      );
      if (dependencyLayers.isEmpty || dependencyLayers.length > 1) {
        continue;
      }
      final dependencyLayer = dependencyLayers.single;
      final dependencyRole = detectPackageRole(
        packageRootPath: dependencyRoot,
        readTextFile: readTextFile,
      );
      if (!isImplementationDependencyAllowed(
        selfRole: selfRole,
        selfLayerName: selfLayer.name,
        dependencyRole: dependencyRole,
        dependencyLayerName: dependencyLayer.name,
      )) {
        rule.reportAtNode(
          node,
          arguments: [
            "Dependency '$dependencyName' is @implementation (or both) and "
                'may only be depended on by same-layer @injection packages '
                '(self role=${selfRole.name}, layer=${selfLayer.name} → '
                'dep layer=${dependencyLayer.name}).',
          ],
        );
      }
    }
  }
}
