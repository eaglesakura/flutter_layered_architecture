# testing_golden ハーネス

共通処理は画面 package に散らさず、プロジェクトの `testing_golden`（または同等）に集約する。
本 SKILL の [assets/testing_golden](../assets/testing_golden/) を複製し、Theme・フォント・ロケール・端末カタログをプロジェクトに合わせて調整する。

## 提供する API（推奨セット）

| API | 用途 |
| --- | --- |
| `goldenTestExecutable` | `flutter_test_config.dart` の共通初期化（binding・フォント・Alchemist platform 設定） |
| `goldenTestMain` | テストファイル `main` のエントリー（出力パス・diffThreshold） |
| `goldenTestPumpWidget` | 標準 pump（Theme・ロケール・アニメ停止。レイアウト例外は失敗） |
| `goldenTestPumpWidgetWithoutException` | 外部ライブラリ起因のレイアウト例外のみ握りつぶす |
| `GoldenDevices` / `GoldenDevice` | 端末寸法カタログ（`constraints`） |
| （任意）ローカライズ inject / reset | 本番 ARB 等から文字列をテストへ注入 |

## 初期化でやること

1. `TestWidgetsFlutterBinding.ensureInitialized()`
2. Golden 描画に必要なフォントを `FontLoader` 等で登録（プロジェクトの日本語・アイコン・絵文字）
3. `AlchemistConfig.runWithConfig` で platform golden の対象 OS・`obscureText` 等を固定

Theme を Alchemist の `AlchemistConfig.theme` に渡せない／型が合わない場合は、**pump 側の `MaterialApp.theme` だけ**を見た目の供給源にする。

## pump でやること

* ルートを `MaterialApp`（またはプロジェクトの App シェル）で包む
* `TickerMode(enabled: false)` と `MediaQuery.disableAnimations` でアニメを止め、フレーム差分を減らす
* 画像がある場合は `RenderImage` のデコード完了を待ってから比較する
* 既定はレイアウトオーバーフローを **失敗**にする

## 端末サイズ

既存 Screen Golden は代表 1 端末（例: `GoldenDevices.iPhone17.constraints`）に揃えるとレビューしやすい。
複数端末が必要なら状態ごとに増やすのではなく、まず代表端末で状態網羅を優先する。

## プロジェクト調整ポイント（assets のコメント箇所）

* Theme / Design System
* フォントアセットの package・パス
* ローカライズ注入の仕組み
* platform golden の `HostPlatform`（macOS のみ等）
* `diffThreshold` の既定値
