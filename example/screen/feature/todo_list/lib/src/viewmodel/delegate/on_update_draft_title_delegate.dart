import 'package:screen_feature_todo_list/src/viewmodel/state/todo_list_screen_state.dart';
import 'package:state_stream/state_stream.dart';

/// Updates the draft title in the screen state stream.
final class OnUpdateDraftTitleDelegate {
  final MutableStateStream<TodoListScreenState> _state;

  /// Creates an [OnUpdateDraftTitleDelegate].
  const OnUpdateDraftTitleDelegate({
    required MutableStateStream<TodoListScreenState> state,
  }) : _state = state;

  /// Executes the draft update for [title].
  Future<void> execute(String title) {
    return _state.updateWithLock((current, emitter) {
      return emitter.emit(current.copyWith(draftTitle: title));
    });
  }
}
