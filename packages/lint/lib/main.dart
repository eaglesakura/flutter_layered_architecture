// ignore_for_file: flutter_layered_architecture_lint/unexported_public_must_be_internal, flutter_layered_architecture_lint/public_type_file_name
import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:flutter_layered_architecture_lint/src/architecture_layer/architecture_layer_dependency.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_execute_method.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_immutable.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_internal.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_no_nested_delegate.dart';
import 'package:flutter_layered_architecture_lint/src/delegate/delegate_no_usecase_instantiation.dart';
import 'package:flutter_layered_architecture_lint/src/file_layout/one_public_type_per_file.dart';
import 'package:flutter_layered_architecture_lint/src/file_layout/public_type_file_name.dart';
import 'package:flutter_layered_architecture_lint/src/file_layout/unexported_public_must_be_internal.dart';
import 'package:flutter_layered_architecture_lint/src/stateful/stateful_closes_mutable_state_stream.dart';
import 'package:flutter_layered_architecture_lint/src/stateful/stateful_has_mutable_state_stream.dart';
import 'package:flutter_layered_architecture_lint/src/stateful/stateful_immutable.dart';
import 'package:flutter_layered_architecture_lint/src/stateful/stateful_methods_use_delegate.dart';
import 'package:flutter_layered_architecture_lint/src/stateful/stateful_mutable_state_stream_freezed.dart';
import 'package:flutter_layered_architecture_lint/src/usecase/usecase_immutable.dart';
import 'package:flutter_layered_architecture_lint/src/usecase/usecase_method_signature.dart';
import 'package:flutter_layered_architecture_lint/src/usecase/usecase_single_method.dart';
import 'package:flutter_layered_architecture_lint/src/view_model/view_model_entity_differs_from_state.dart';
import 'package:flutter_layered_architecture_lint/src/view_model/view_model_entity_freezed.dart';
import 'package:flutter_layered_architecture_lint/src/view_model/view_model_has_entity_getter.dart';
import 'package:flutter_layered_architecture_lint/src/view_model/view_model_internal.dart';
import 'package:flutter_layered_architecture_lint/src/view_model/view_model_on_method_names.dart';

/// Analyzer プラグインのエントリポイント.
final plugin = FlutterLayeredArchitecturePlugin();

/// Flutter Layered Architecture 向け analyzer プラグイン.
final class FlutterLayeredArchitecturePlugin extends Plugin {
  @override
  String get name => 'flutter_layered_architecture_lint';

  @override
  void register(PluginRegistry registry) {
    registry.registerWarningRule(OnePublicTypePerFile());
    registry.registerWarningRule(PublicTypeFileName());
    registry.registerWarningRule(UnexportedPublicMustBeInternal());
    registry.registerWarningRule(UsecaseSingleMethod());
    registry.registerWarningRule(UsecaseMethodSignature());
    registry.registerWarningRule(UsecaseImmutable());
    registry.registerWarningRule(DelegateExecuteMethod());
    registry.registerWarningRule(DelegateImmutable());
    registry.registerWarningRule(DelegateInternal());
    registry.registerWarningRule(DelegateNoNestedDelegate());
    registry.registerWarningRule(DelegateNoUsecaseInstantiation());
    registry.registerWarningRule(StatefulImmutable());
    registry.registerWarningRule(StatefulHasMutableStateStream());
    registry.registerWarningRule(StatefulClosesMutableStateStream());
    registry.registerWarningRule(StatefulMutableStateStreamFreezed());
    registry.registerWarningRule(StatefulMethodsUseDelegate());
    registry.registerWarningRule(ViewModelInternal());
    registry.registerWarningRule(ViewModelHasEntityGetter());
    registry.registerWarningRule(ViewModelEntityFreezed());
    registry.registerWarningRule(ViewModelEntityDiffersFromState());
    registry.registerWarningRule(ViewModelOnMethodNames());
    registry.registerWarningRule(ArchitectureLayerDependency());
  }
}
