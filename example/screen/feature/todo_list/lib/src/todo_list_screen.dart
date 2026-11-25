import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:screen_feature_todo_list/src/view/todo_list_screen_impl.dart';
import 'package:screen_feature_todo_list/src/viewmodel/todo_list_screen_viewmodel.dart';

/// Public entry point for the todo list screen.
final class TodoListScreen extends HookConsumerWidget {
  /// Creates a [TodoListScreen].
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(TodoListScreenViewModel.provider);

    useEffect(() {
      viewModel.onInitialize();
      return null;
    }, [viewModel]);

    return const TodoListScreenImpl();
  }
}
