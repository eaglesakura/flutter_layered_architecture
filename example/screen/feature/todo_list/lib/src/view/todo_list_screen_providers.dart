import 'package:meta/meta.dart';
import 'package:screen_feature_todo_list/src/viewmodel/todo_list_screen_viewmodel.dart';
import 'package:state_stream_riverpod/state_stream_riverpod.dart';

/// Riverpod providers for the todo list screen View.
@internal
final class TodoListScreenProviders {
  /// Entity provider derived from [TodoListScreenViewModel.entity].
  static final entity = StateStreamProvider.autoDispose.stateBy(
    TodoListScreenViewModel.provider,
    (viewModel) => viewModel.entity,
  );
}
