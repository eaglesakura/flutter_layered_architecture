# unexported_public_must_be_internal

`lib/` バレル（`library;`）に export されていない公開トップレベルシンボルは、`@internal` にするか private にする。

## Details

DO パッケージの公開面に載っていない公開トップレベルシンボルには `@internal` を付けるか、private にする。公開面はバレルファイルの `exportNamespace` である。バレルは `lib/*.dart` のうち `library;`（名前付き `library ...;` も含む）を宣言したファイルである。そのようなバレルが無いパッケージはスキップされる。

対象は公開トップレベルの `class` / `enum` / `mixin` / 名前付き `extension` / `extension type` / 関数 / 変数 / `typedef` である。`part of` ファイルと `test/` 配下は対象外である。Severity は WARNING である。

関連アノテーション: `@internal`（`package:meta`）。

BAD:

```dart
// lib/src/hidden_helper.dart（バレル未 export）
final class HiddenHelper {
  const HiddenHelper();
}
```

GOOD:

```dart
// lib/src/hidden_helper.dart
@internal
final class HiddenHelper {
  const HiddenHelper();
}
```

## Enable

本ルールは `flutter_layered_architecture_lint` analyzer プラグインに含まれる。ワークスペースルートの `analysis_options.yaml` でプラグインを有効化する:

```yaml
plugins:
  flutter_layered_architecture_lint:
    path: packages/lint
```

Dart 3.14+（Flutter 3.50+）が必要である。`plugins:` を変更したら Dart Analysis Server を再起動する。

## Suppress

```dart
// ignore: flutter_layered_architecture_lint/unexported_public_must_be_internal
```
