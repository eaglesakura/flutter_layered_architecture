import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Entrypoint for `custom_lint`.
PluginBase createPlugin() => _FlutterLayeredArchitectureLint();

class _FlutterLayeredArchitectureLint extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [];
}
