import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';
import 'package:screen_feature_todo_list/src/view/todo_list_screen_providers.dart';
import 'package:screen_feature_todo_list/src/viewmodel/entity/todo_list_screen_entity.dart';
import 'package:screen_feature_todo_list/src/viewmodel/todo_list_screen_viewmodel.dart';

/// Visual implementation of the todo list screen.
@internal
final class TodoListScreenImpl extends HookConsumerWidget {
  /// Creates a [TodoListScreenImpl].
  const TodoListScreenImpl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = ref.watch(TodoListScreenProviders.entity);
    final titleController = useTextEditingController();

    useEffect(() {
      if (titleController.text != entity.draftTitle) {
        titleController.value = TextEditingValue(
          text: entity.draftTitle,
          selection: TextSelection.collapsed(offset: entity.draftTitle.length),
        );
      }
      return null;
    }, [entity.draftTitle]);

    return Scaffold(
      appBar: AppBar(title: const Text('Layered TODO')),
      body: entity.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'New TODO',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            ref
                                .read(TodoListScreenViewModel.provider)
                                .onUpdateDraftTitle(value);
                          },
                          onSubmitted: (_) {
                            if (entity.canAdd) {
                              ref
                                  .read(TodoListScreenViewModel.provider)
                                  .onAddTodo();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: entity.canAdd
                            ? () {
                                ref
                                    .read(TodoListScreenViewModel.provider)
                                    .onAddTodo();
                              }
                            : null,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: entity.items.isEmpty
                      ? const Center(child: Text('No TODOs yet'))
                      : ListView.separated(
                          itemCount: entity.items.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = entity.items[index];
                            return _TodoListTile(item: item);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

final class _TodoListTile extends ConsumerWidget {
  final TodoListItemEntity item;

  const _TodoListTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Checkbox(
        value: item.isCompleted,
        onChanged: (_) {
          ref.read(TodoListScreenViewModel.provider).onToggleTodo(item.id);
        },
      ),
      title: Text(
        item.title,
        style: item.isCompleted
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () {
          ref.read(TodoListScreenViewModel.provider).onDeleteTodo(item.id);
        },
      ),
    );
  }
}
