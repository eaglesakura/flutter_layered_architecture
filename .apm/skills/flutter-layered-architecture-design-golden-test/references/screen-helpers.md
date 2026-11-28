# 画面 Golden ヘルパーとテスト骨格

## helpers: buildGoldenScreen

```dart
Widget buildGoldenScreen({
  required XxxScreenState state,
  XxxScreenStateToEntityDelegate delegate =
      const XxxScreenStateToEntityDelegate(),
}) {
  final entity = delegate.execute(state);
  return ProviderScope(
    overrides: [
      XxxScreenProviders.entity.overrideWithBuild(
        (ref, self) => entity,
      ),
    ],
    child: const XxxScreenImpl(),
  );
}
```

* State ファクトリは `newGoldenScreenStateLoading()` のように状態名を関数名に入れる
* Event は見た目に影響しないなら `nothing` 固定でよい
* Scaffold / AppBar が ScreenImpl 内にあるなら二重に包まない。Impl が body だけのときは helpers 側で `Scaffold` を足してよい

## テストファイル骨格

```dart
void main() => goldenTestMain(() {
  const delegate = XxxScreenStateToEntityDelegate();

  setUpAll(() async {
    // 必要なら: await testContext.injectForTesting();
    await injectGoldenTestLocalization(); // プロジェクトに無い場合は省略
  });

  tearDownAll(() async {
    await resetGoldenTestLocalization();
  });

  group("XxxScreen Golden Tests", () {
    goldenTest(
      "xxx_screen_loading",
      fileName: "xxx_screen/loading",
      builder: () => buildGoldenScreen(
        state: newGoldenScreenStateLoading(),
        delegate: delegate,
      ),
      constraints: GoldenDevices.iPhone17.constraints,
      pumpWidget: goldenTestPumpWidget,
    );
  });
});
```

コメントで「テスト対象」「テスト内容（どの State のとき何が見えるか）」を残すとレビューしやすい。

## DI が必要な場合

State にアプリメタデータ等の本番値が要るときだけ `testing_injection` を併用する。

* `setUpAll` で `injectForTesting` のあと `ref.read(...)` で値を取り、State ファクトリへ渡す
* Golden のルートは依然として ScreenImpl + Entity override（ViewModel は起動しない）

## Entity 直注入の helpers

```dart
Widget buildGoldenScreen({required XxxScreenEntity entity}) {
  return ProviderScope(
    overrides: [
      XxxScreenProviders.entity.overrideWithBuild((ref, self) => entity),
    ],
    child: const Scaffold(body: XxxScreenImpl()),
  );
}
```

変換分岐が無い・Entity が薄い画面向け。新規は State + Delegate を優先。
