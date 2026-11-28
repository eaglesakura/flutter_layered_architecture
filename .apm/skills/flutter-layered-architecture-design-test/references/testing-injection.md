# testing_injection — `_test` 向け一括結線

## 役割

`_test` package が **ロジック系 Usecase / Repository の実体**を使えるように、IF `provider` へ本番 Impl（または Testing\*）を bind する。
app の本番 `inject()` とは **非正規化で二重管理**してよい。app への依存は持たない。

```dart
extension TestContextInjectionExtensions on TestContext {
  Future<void> injectForTesting() async {
    await _injectForTestingInfra(refBuilder);
    await _injectForTestingData(refBuilder);
    await _injectForTestingUsecase(refBuilder);
  }
}
```

推奨の層順（下位 → 上位）は本番と同じ:

1. Infra（Storage / Firebase 等のテスト用 inject）
2. Data
3. Usecase
4. 必要なら Screen（Unit では省略することが多い）

## part 分割

DI と Dart の仕様上、この処理は実装モジュールへの暗黙参照が広がる。
層ごとに part へ分け、見通しと差分を小さくする。

```text
test_context_inject_for_testing.dart           # extension + injectForTesting
test_context_inject_for_testing.infra.dart     # part
test_context_inject_for_testing.data.dart      # part
test_context_inject_for_testing.usecase.dart   # part
```

参考実装: [../assets/testing_injection/lib/](../assets/testing_injection/lib/)

## 結線の形

本番の `{layer}_injection` と同じく、IF → 実装の `inject` を並べる。

```dart
builder.inject(AddTodoUsecase.provider, AddTodoUsecaseImpl.provider);
builder.inject(TodoRepository.provider, InMemoryTodoRepository.provider);
```

* Infra で Unit 再現が難しいものは `Testing*Injection.inject(builder)` や Testing\* provider に差し替えてよい
* Data のうち「各テストで Mock したい」もの（例: アカウント）は、ここでは結線せずテスト側で `overrideWithValue` してもよい（コメントで明示する）

## `_test` での利用

```dart
setUp(() async {
  await testContext.injectForTesting();
  usecase = await ref.testReady(AddTodoUsecase.provider);
});
```

* `ref.testReady` は `riverpod_container_async_test` 等のプロジェクト慣例に従う
* 追加の差し替えは `injectForTesting` の前後で `refBuilder.inject` / `injectValue` してよい

## app との関係

| | app 本番 inject | testing_injection |
| --- | --- | --- |
| 置き場 | app / feature | `app_packages/testing/injection` 等 |
| 依存 | 実装モジュールを集約 | 同様だが **app を依存にしない** |
| 目的 | 起動時 Container | Unit Test の依存解決 |

抜けた bind は IF stub の `UnimplementedError` で気づける。本番追加時は testing 側も更新する運用にする。
