part of "test_context_inject_for_testing.dart";

/// Unit Test向けUsecase層Providerを[builder]へ注入する。
///
/// NOTE.
/// app の Usecase injection と同等の本番実装を登録する。
Future<void> _injectForTestingUsecase(DependencyBuilder builder) async {
  builder.inject(
    AddTodoUsecase.provider,
    AddTodoUsecaseImpl.provider,
  );
  builder.inject(
    ListTodosUsecase.provider,
    ListTodosUsecaseImpl.provider,
  );
  builder.inject(
    ToggleTodoUsecase.provider,
    ToggleTodoUsecaseImpl.provider,
  );
  builder.inject(
    DeleteTodoUsecase.provider,
    DeleteTodoUsecaseImpl.provider,
  );
}
