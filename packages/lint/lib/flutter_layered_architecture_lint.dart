import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_execute_method.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_immutable.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_internal.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_no_nested_delegate.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_no_usecase_instantiation.dart';
import 'package:flutter_layered_architecture_lint/src/stateful/stateful_closes_mutable_state_stream.dart';
import 'package:flutter_layered_architecture_lint/src/stateful/stateful_has_mutable_state_stream.dart';
import 'package:flutter_layered_architecture_lint/src/stateful/stateful_immutable.dart';
import 'package:flutter_layered_architecture_lint/src/stateful/stateful_methods_use_delegate.dart';
import 'package:flutter_layered_architecture_lint/src/stateful/stateful_mutable_state_stream_freezed.dart';
import 'package:flutter_layered_architecture_lint/src/usecase/usecase_immutable.dart';
import 'package:flutter_layered_architecture_lint/src/usecase/usecase_method_signature.dart';
import 'package:flutter_layered_architecture_lint/src/usecase/usecase_single_method.dart';

/// `custom_lint` 向けプラグインのエントリポイントを返す.
///
/// Example:
/// ```dart
/// // custom_lint が自動で呼び出す.
/// final plugin = createPlugin();
/// ```
PluginBase createPlugin() => _FlutterLayeredArchitectureLint();

/// Flutter Layered Architecture 向け custom_lint プラグイン.
class _FlutterLayeredArchitectureLint extends PluginBase {
  /// 有効な Lint ルール一覧を返す.
  ///
  /// [configs] は analysis_options 由来の custom_lint 設定.
  ///
  /// Example:
  /// ```dart
  /// final rules = plugin.getLintRules(CustomLintConfigs.empty);
  /// ```
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    const UsecaseSingleMethod(),
    const UsecaseMethodSignature(),
    const UsecaseImmutable(),
    const DelegateExecuteMethod(),
    const DelegateImmutable(),
    const DelegateInternal(),
    const DelegateNoNestedDelegate(),
    const DelegateNoUsecaseInstantiation(),
    const StatefulImmutable(),
    const StatefulHasMutableStateStream(),
    const StatefulClosesMutableStateStream(),
    const StatefulMutableStateStreamFreezed(),
    const StatefulMethodsUseDelegate(),
  ];
}
