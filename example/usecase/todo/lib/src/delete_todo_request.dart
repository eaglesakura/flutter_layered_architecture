/// Request for DeleteTodoUsecase.
final class DeleteTodoRequest {
  /// Target todo id.
  final String id;

  /// Creates a [DeleteTodoRequest].
  const DeleteTodoRequest({required this.id});
}
