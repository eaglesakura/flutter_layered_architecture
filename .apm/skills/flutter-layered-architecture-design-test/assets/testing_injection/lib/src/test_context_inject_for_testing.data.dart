part of "test_context_inject_for_testing.dart";

/// Unit Test向けData層Providerを[builder]へ注入する。
///
/// NOTE.
/// app の Data injection と非正規化で同等バインドを持つ（app へ依存しない）。
Future<void> _injectForTestingData(DependencyBuilder builder) async {
  builder.inject(
    TodoRepository.provider,
    InMemoryTodoRepository.provider,
  );
}
