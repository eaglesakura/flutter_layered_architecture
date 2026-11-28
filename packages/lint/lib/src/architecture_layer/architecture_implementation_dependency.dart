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

/// `_impl` package への依存を同一レイヤー `_injection` に限定する Lint（WARNING）.
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
            'Warns when a non-_injection or cross-layer package depends on '
            '_impl packages.',
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

  /// 定義 yaml 正規化パス → ignore 設定診断の二重報告防止.
  static final Set<String> _reportedDefinitionPaths = {};
  static const _ignoreConfigKeyPrefix = '__ignore_config__:';

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

    final ignoreParse = parseArchitectureImplementationDependencyIgnore(
      definitionYamlText,
    );
    var ignoreValid = false;
    var ignoreEntries = <String>[];
    if (ignoreParse is ArchitectureImplementationIgnoreParseFailure) {
      _reportIgnoreConfigOnce(
        node,
        definitionPath,
        'Invalid rules.architecture_implementation_dependency.ignore: '
        '${ignoreParse.message}',
      );
    } else {
      ignoreEntries =
          (ignoreParse as ArchitectureImplementationIgnoreParseSuccess)
              .entries;
      ignoreValid = true;
    }

    final packageRoots = packageRootsFromPackageConfig(
      packageConfigJsonText: packageConfigText,
      packageConfigFileDirectory: p.dirname(packageConfigPath),
    );

    if (ignoreValid) {
      final missing = unresolvedIgnorePackageNames(
        ignoreNames: ignoreEntries,
        packageRoots: packageRoots,
      );
      if (missing.isNotEmpty) {
        _reportIgnoreConfigOnce(
          node,
          definitionPath,
          'Unknown package name(s) in '
          'rules.architecture_implementation_dependency.ignore: '
          '${missing.join(', ')}',
        );
        ignoreValid = false;
      }
    }

    final selfPackageName = parsePackageNameFromPubspecYaml(pubspecText);
    if (shouldSkipDependencyDirectionForPackage(
      ignoreConfigValid: ignoreValid,
      ignoreEntries: ignoreEntries,
      selfPackageName: selfPackageName,
    )) {
      return;
    }

    final selfRole = packageRoleFromPackageName(selfPackageName);
    final direct = parseDirectDependencyNames(pubspecText);
    final dependencyNames = <String>{
      ...direct.dependencies,
      ...direct.devDependencies,
    };

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
      final dependencyRole = packageRoleFromPackageName(dependencyName);
      if (!isImplementationDependencyAllowed(
        selfRole: selfRole,
        selfLayerName: selfLayer.name,
        dependencyRole: dependencyRole,
        dependencyLayerName: dependencyLayer.name,
      )) {
        final message =
            "Dependency '$dependencyName' is an _impl package and "
            'may only be depended on by same-layer _injection packages '
            '(self role=${selfRole.name}, layer=${selfLayer.name} → '
            'dep layer=${dependencyLayer.name}).';
        rule.reportAtNode(node, arguments: [message]);
      }
    }
  }

  void _reportIgnoreConfigOnce(
    CompilationUnit node,
    String definitionPath,
    String message,
  ) {
    final key = '$_ignoreConfigKeyPrefix$definitionPath';
    if (_reportedDefinitionPaths.contains(key)) {
      return;
    }
    _reportedDefinitionPaths.add(key);
    rule.reportAtNode(node, arguments: [message]);
  }
}
