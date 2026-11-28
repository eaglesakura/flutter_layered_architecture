import "dart:async";

import "package:alchemist/alchemist.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart" show RenderImage;
import "package:flutter_test/flutter_test.dart";

/// Golden Test 実行前の共通初期化（参考実装）。
///
/// NOTE.
/// フォント読込・platform golden 対象 OS・Theme 供給はプロジェクトで差し替える。
/// 見た目 Theme を [AlchemistConfig.theme] に渡せない場合は
/// [goldenTestPumpWidget] の [MaterialApp] だけを供給源にする。
///
/// Example:
/// ```dart
/// Future<void> testExecutable(FutureOr<void> Function() testMain) =>
///     goldenTestExecutable(testMain);
/// ```
Future<void> goldenTestExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // TODO(project): 日本語・アイコン・絵文字フォントを FontLoader で登録する.
  // await loadGoldenTestFonts();

  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(
        // TODO(project): CI とローカルの HostPlatform を合わせる（例: macOS のみ）.
        platforms: {HostPlatform.macOS},
        obscureText: false,
      ),
    ),
    run: testMain,
  );
}

/// Alchemist の共通設定を適用して Golden Test を実行する。
///
/// Golden Image の出力先は `goldens/{environmentName}/{fileName}.png`。
void goldenTestMain(
  void Function() main, {
  double diffThreshold = 0.001,
}) {
  AlchemistConfig.runWithConfig(
    config: AlchemistConfig.current().merge(
      AlchemistConfig(
        platformGoldensConfig: PlatformGoldensConfig(
          filePathResolver: (fileName, environmentName) {
            return "goldens/$environmentName/$fileName.png";
          },
          obscureText: false,
          diffThreshold: diffThreshold,
        ),
        ciGoldensConfig: CiGoldensConfig(
          filePathResolver: (fileName, environmentName) {
            return "goldens/$environmentName/$fileName.png";
          },
          diffThreshold: diffThreshold,
        ),
      ),
    ),
    run: main,
  );
}

/// Alchemist 用の標準 pump（レイアウト例外は失敗）。
///
/// NOTE.
/// Theme・ロケールはプロジェクトの Design System / l10n に差し替える。
/// [TickerMode] と [MediaQueryData.disableAnimations] でアニメを止め再現性を確保する。
Future<void> goldenTestPumpWidget(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(
    TickerMode(
      enabled: false,
      child: MaterialApp(
        // TODO(project): ThemeData をプロジェクトの Theme に差し替える.
        theme: ThemeData.light(),
        locale: const Locale("ja"),
        supportedLocales: const [Locale("ja")],
        // TODO(project): flutter_localizations やプロジェクト l10n delegates を足す.
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: true,
            ),
            child: child!,
          );
        },
        home: widget,
      ),
    ),
  );
  await _waitForAllImagesToLoad(tester);
}

/// 外部ライブラリ都合でレイアウト例外が不可避なときだけ使う pump。
///
/// 利用時は呼び出し側の `goldenTest` に原因ライブラリを `NOTE.` で残す。
Future<void> goldenTestPumpWidgetWithoutException(
  WidgetTester tester,
  Widget widget,
) async {
  await goldenTestPumpWidget(tester, widget);

  final exception = tester.takeException();
  if (exception != null) {
    debugPrint("DROP ERROR: $exception");
  }
}

Future<void> _waitForAllImagesToLoad(WidgetTester tester) async {
  const maxAttempts = 100;

  bool hasUnloadedImages(Element root) {
    var pending = false;
    void walk(Element element) {
      final renderObject = element.renderObject;
      if (renderObject is RenderImage && renderObject.image == null) {
        pending = true;
      }
      element.visitChildren(walk);
    }

    walk(root);
    return pending;
  }

  for (var i = 0; i < maxAttempts; i++) {
    if (!hasUnloadedImages(tester.binding.rootElement!)) {
      return;
    }
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
  }
  throw StateError("Images did not load within $maxAttempts attempts");
}
