/// Request for AddTodoUsecase.
final class AddTodoRequest {
  /// Title entered by the user.
  final String title;

  /// Creates an [AddTodoRequest].
  const AddTodoRequest({required this.title});
}
