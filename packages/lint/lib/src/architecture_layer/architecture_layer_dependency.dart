import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_layer/architecture_layer_checkers.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_lint.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

/// pubspec 依存のレイヤー level 制約を検証する Lint（すべて WARNING）.
///
/// 検査対象は `layererd_architecture.yaml` のいずれかの `path_prefix` に所属する
/// package のみ。定義不在・YAML 不正・path_prefix 事前チェック・level 違反を報告する.
///
/// Example:
/// ```dart
/// // domain_todo が usecase_todo に直接依存 → architecture_layer_dependency
/// ```
@internal
final class ArchitectureLayerDependency extends AnalysisRule {
  /// [ArchitectureLayerDependency] の診断コード（メッセージは `{0}` で可変）.
  static const LintCode code = LintCode(
    'architecture_layer_dependency',
    '{0}',
    severity: architectureViolationSeverity,
  );

  /// [ArchitectureLayerDependency] ルールを生成する.
  ArchitectureLayerDependency()
    : super(
        name: 'architecture_layer_dependency',
        description:
            'Warns when a package depends on a higher architecture layer.',
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

/// CompilationUnit ごとに package 単位の依存検査を 1 回だけ実行する Visitor.
final class _Visitor extends SimpleAstVisitor<void> {
  /// 正規化 package root → 依存検査の二重実行防止（プロセス生存中クリアなし）.
  static final Set<String> _reportedPackageRoots = {};

  /// 定義 yaml 正規化パス（または missing 用 synthetic キー）→ 定義スコープ診断の二重報告防止.
  static final Set<String> _reportedDefinitionPaths = {};
  static const _missingDefinitionKeyPrefix = '__missing__:';

  final ArchitectureLayerDependency rule;

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
      _reportMissingDefinitionOnce(node, packageRoot);
      return;
    }

    final definitionYamlText = readTextFile(definitionPath);
    if (definitionYamlText == null) {
      _reportMissingDefinitionOnce(node, packageRoot);
      return;
    }

    final parseResult = parseLayerArchitectureYaml(definitionYamlText);
    if (parseResult is LayerArchitectureParseFailure) {
      if (!_reportedDefinitionPaths.contains(definitionPath)) {
        _reportedDefinitionPaths.add(definitionPath);
        _report(
          node,
          'Invalid layererd_architecture.yaml: ${parseResult.message}',
        );
      }
      return;
    }

    final definition = parseResult as LayerArchitectureDefinition;
    final definitionDir = normalizePathForCompare(p.dirname(definitionPath));

    final selfLayers = layersForPackagePath(
      definitionDir: definitionDir,
      layers: definition.layers,
      packageRootPath: packageRoot,
    );
    if (selfLayers.isEmpty) {
      return;
    }

    if (!_reportedDefinitionPaths.contains(definitionPath)) {
      _reportedDefinitionPaths.add(definitionPath);
      final overlaps = findPathPrefixOverlaps(
        definitionDir: definitionDir,
        layers: definition.layers,
      );
      for (final overlap in overlaps) {
        _report(
          node,
          'Overlapping path_prefix between ${overlap.layerA} and '
          '${overlap.layerB}: ${overlap.reason}',
        );
      }
    }

    final packageConfigPath = findPackageConfigJson(packageRoot);
    if (packageConfigPath == null) {
      return;
    }
    final packageConfigText = readTextFile(packageConfigPath);
    if (packageConfigText == null) {
      return;
    }

    final pubspecPath = p.join(packageRoot, 'pubspec.yaml');
    final pubspecText = readTextFile(pubspecPath);
    if (pubspecText == null) {
      return;
    }

    final directDependencies = parseDirectDependencyNames(pubspecText);
    final dependencyNames = <String>{
      ...directDependencies.dependencies,
      ...directDependencies.devDependencies,
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
      if (dependencyLayers.isEmpty) {
        continue;
      }

      if (!hasAnyLevelViolation(
        selfLayers: selfLayers,
        dependencyLayers: dependencyLayers,
      )) {
        continue;
      }

      final message = _dependencyViolationMessage(
        dependencyName: dependencyName,
        selfLayers: selfLayers,
        dependencyLayers: dependencyLayers,
      );
      if (message != null) {
        _report(node, message);
      }
    }
  }

  /// level 違反があれば、厳格 OR の最初の違反ペアからメッセージを組み立てる.
  String? _dependencyViolationMessage({
    required String dependencyName,
    required List<ArchitectureLayer> selfLayers,
    required List<ArchitectureLayer> dependencyLayers,
  }) {
    for (final selfLayer in selfLayers) {
      for (final dependencyLayer in dependencyLayers) {
        if (!isLevelViolation(
          selfLayer: selfLayer,
          dependencyLayer: dependencyLayer,
        )) {
          continue;
        }
        return "Dependency '$dependencyName' (layer ${dependencyLayer.name} "
            'level ${dependencyLayer.level}) violates constraint from layer '
            '${selfLayer.name} level ${selfLayer.level}.';
      }
    }
    return null;
  }

  String _missingDefinitionDedupKey(String packageRoot) {
    return '$_missingDefinitionKeyPrefix$packageRoot';
  }

  void _report(CompilationUnit node, String message) {
    rule.reportAtNode(node, arguments: [message]);
  }

  void _reportMissingDefinitionOnce(CompilationUnit node, String packageRoot) {
    final key = _missingDefinitionDedupKey(packageRoot);
    if (_reportedDefinitionPaths.contains(key)) {
      return;
    }
    _reportedDefinitionPaths.add(key);
    _report(
      node,
      'layererd_architecture.yaml not found when searching upward from the '
      'package root.',
    );
  }
}
