# ファイルレイアウトと命名

## 画面 package 内（推奨）

```text
{screen_feature_package}/
  test/
    flutter_test_config.dart          # goldenTestExecutable
    golden/
      {画面名}_golden_test.dart
      helpers/{画面名}_golden_helpers.dart
      goldens/
        CI/{fileName}.png             # CI 比較（テキスト潰し等）
        macOS/{fileName}.png          # platform 参照（文字込み。環境名はプロジェクトで可）
    viewmodel/                        # Delegate / VM Unit Test（Golden 以外）
```

View コンポーネント単体も同じ `test/golden/` 配下に揃えると、ハーネスと CI パスが共通化できる。

## 命名

| 項目 | 規則 | 例 |
| --- | --- | --- |
| テスト名（`goldenTest` 第1引数） | `{画面名}_{状態の説明}` | `eula_screen_loading` |
| `fileName` | `{画面名}/{状態の説明}` | `eula_screen/loading` |
| ヘルパー | `buildGoldenScreen`, `newGoldenScreenState{状態}` | `newGoldenScreenStateLoading()` |
| Entity 直注入時 | `newGoldenEntity{状態}` | `newGoldenEntityEmptyInput()` |

`fileName` は Alchemist の resolver により `goldens/{environmentName}/{fileName}.png` になる想定（ハーネス側で固定）。

## flutter_test_config.dart

```dart
import "dart:async";

import "package:testing_golden/testing_golden.dart";

Future<void> testExecutable(FutureOr<void> Function() testMain) =>
    goldenTestExecutable(testMain);
```

package の `test/` 直下に置き、Golden 実行前のフォント読込・Alchemist 設定を共通化する。

## pubspec（画面側の例）

```yaml
dev_dependencies:
  alchemist: any
  testing_golden: any
```

メタデータや本番 DI が State 組み立てに必要な画面だけ、`testing_core` / `testing_injection` 等を追加する（`design-test`）。
