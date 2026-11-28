# レイアウト例外

## 原則

**レイアウト例外はテストで検出し、修正する。** 既定の pump は `goldenTestPumpWidget`（例外を失敗にする）。

## 例外クリアが許される場合

`goldenTestPumpWidgetWithoutException` は、**利用ライブラリ都合で例外が不可避な場合のみ**使う。

* `goldenTest` の直前（または `pumpWidget:` の直上）に、原因ライブラリと症状を `NOTE.` コメントで残す
* 自前 Widget の Overflow を隠す用途には使わない

```dart
// NOTE. ExampleSignInButton の描画で OverflowBarError が発生するため、例外をクリアする.
pumpWidget: goldenTestPumpWidgetWithoutException,
```

ハーネス実装では `tester.takeException()` で例外を落とし、`debugPrint` 等でログを残すと調査しやすい。
