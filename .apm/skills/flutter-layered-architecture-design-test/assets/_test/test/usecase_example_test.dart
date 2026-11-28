import "package:flutter_test/flutter_test.dart";
import "package:riverpod_container_async_test/riverpod_container_async_test.dart";
import "package:testing_core/testing_core.dart";
import "package:testing_injection/testing_injection.dart";
import "package:usecase_todo/usecase_todo.dart";

void main() {
  late AddTodoUsecase addTodoUsecase;

  setUp(() async {
    await testContext.injectForTesting();
    addTodoUsecase = await ref.testReady(AddTodoUsecase.provider);
  });

  // テスト対象:
  // usecase_todo/AddTodoUsecase
  //
  // テスト内容:
  // testing_injection 経由で本番 Impl が取得でき、追加できること。
  test("実体DIでTodoを追加できる", () async {
    final todo = await addTodoUsecase.execute(
      const AddTodoRequest(title: "buy milk"),
    );
    expect(todo.title, "buy milk");
  });
}
