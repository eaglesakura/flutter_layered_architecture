# testing_core — TestContext を使いやすくする

## 役割

`armyknife_test_context` の `TestContext` は、テストごとに 1 インスタンスが保証されるコンテキストである。
`testing_core` はここに **DI ビルダーと ProviderContainer** を載せ、テストから短い API で触れるようにする。

| API | 意味 |
| --- | --- |
| `testContext` | 実行中 `TestContext.current()` |
| `refBuilder` | テスト用 DI ビルダー（未 build）。`inject` の受け口 |
| `ref` | `refBuilder.build()` した `ProviderContainer`（tearDown で dispose） |
| `isCI` | 任意。CI 環境変数の判定 |

## なぜ TestContext 経由か

* テスト終了時の `disposeAsync` を `onTearDown` に載せる
* `setUp` を跨いでも「今のテストのコンテナ」が明確
* Extension（`injectForTesting`）の owner になる

## 最小実装の要点

参考実装: [../assets/testing_core/lib/](../assets/testing_core/lib/)

1. `WidgetsFlutterBinding.ensureInitialized()` をビルダー生成時に一度行う
2. `refBuilder` を `testContext.value(DependencyBuilder, …)` で lazy 生成
3. `ref` は `refBuilder.build()` し、`onTearDown` で `disposeAsync()`
4. プロジェクト固有の Logger 注入などがあれば、`testContext` getter 側で触る（任意）

ビルダー型はプロジェクトのラッパ（`DependencyBuilder`）でも、`ProviderContainerBuilder` 直使いでもよい。
契約は `design-dependency-injection` の `inject` / `build` に合わせる。

## `_test` からの使い方（入口だけ）

```dart
import "package:testing_core/testing_core.dart";

setUp(() async {
  // injectForTesting は testing_injection 側
  await testContext.injectForTesting();
});
```

`ref` / `refBuilder` は `testing_core` の export 経由で読む。
