# Repository のテスト差し替え

## 優先順位

1. **Mock**（mocktail 等）+ Provider override / コンストラクタ注入 — 画面・VM・Usecase シナリオの既定
2. **package internal Fake** — Repository `_impl` の Unit Test でインフラ境界だけ差し替える
3. **`_testing` の Testing\*** — 特定レイヤー／責務内のテストサポート。振る舞いが厚く Mock だと読めない場合のみ（認証フロー等）。Unit Test 専用の `_test`（leaf）とは別

「emit 用ヘルパー」やカウンタだけの Testing\* は作らない。Mock で足りるなら `_testing` package 自体を作らない。正本: `flutter-layered-architecture-design-test`。

## Fake と本番の分離

* 1 つの Impl が Fake と本番を `if (isTest)` で兼ねない
* 差し替えは DI（override または Testing\* Provider）で行う

## Mock + override の型

```dart
class _MockTodoRepository extends Mock implements TodoRepository {}

setUp(() async {
  final mock = _MockTodoRepository();
  when(() => mock.list()).thenAnswer((_) async => <Todo>[]);
  // Provider を overrideWithValue(mock) 等で差し替え
});
```

`watch` / Stream を返す IF では、`MutableStateStream` や `StreamController` を `thenAnswer` で渡す。

## DO NOT

* 本番 package から `_testing` / `_test` へ依存する（`_test` は lint: `architecture_unit_test_package_dependency`）
* 画面テストのために常に厚い Testing\* を必須にする
