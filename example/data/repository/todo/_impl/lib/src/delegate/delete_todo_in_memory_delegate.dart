import 'package:data_repository_todo_impl/src/in_memory_todo_repository_state.dart';
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';

/// In-memory から Todo を削除する Delegate.
@internal
@delegate
final class DeleteTodoInMemoryDelegate {
  /// Repository state stream.
  final MutableStateStream<InMemoryTodoRepositoryState> state;

  /// Creates a [DeleteTodoInMemoryDelegate].
  const DeleteTodoInMemoryDelegate({
    required this.state,
  });

  /// [id] に一致する Todo を削除する.
  Future<void> execute(String id) {
    return state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          items: [
            for (final item in current.items)
              if (item.id != id) item,
          ],
        ),
      );
    });
  }
}
