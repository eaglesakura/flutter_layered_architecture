/// Request for ToggleTodoUsecase.
final class ToggleTodoRequest {
  /// Target todo id.
  final String id;

  /// Creates a [ToggleTodoRequest].
  const ToggleTodoRequest({required this.id});
}
