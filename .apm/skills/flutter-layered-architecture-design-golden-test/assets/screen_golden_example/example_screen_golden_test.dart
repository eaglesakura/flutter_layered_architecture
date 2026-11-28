import "package:alchemist/alchemist.dart";
import "package:flutter_test/flutter_test.dart";
import "package:testing_golden/testing_golden.dart";

import "helpers/example_screen_golden_helpers.dart";

/// MVVM Screen Golden の骨格例。
///
/// プロジェクトでは本番の StateToEntityDelegate / helpers / 端末制約に差し替える。
void main() => goldenTestMain(() {
      const delegate = ExampleScreenStateToEntityDelegate();

      setUpAll(() async {
        // TODO(project): ローカライズ inject、必要なら injectForTesting。
      });

      tearDownAll(() async {
        // TODO(project): ローカライズ reset。
      });

      group("ExampleScreen Golden Tests", () {
        // テスト対象: ExampleScreenImpl (loading)
        // テスト内容: loading State のときインジケータが表示されること。
        goldenTest(
          "example_screen_loading",
          fileName: "example_screen/loading",
          builder: () => buildGoldenScreen(
            state: newGoldenScreenStateLoading(),
            delegate: delegate,
          ),
          constraints: GoldenDevices.iPhone17.constraints,
          pumpWidget: goldenTestPumpWidget,
        );

        goldenTest(
          "example_screen_loaded",
          fileName: "example_screen/loaded",
          builder: () => buildGoldenScreen(
            state: newGoldenScreenStateLoaded(),
            delegate: delegate,
          ),
          constraints: GoldenDevices.iPhone17.constraints,
          pumpWidget: goldenTestPumpWidget,
        );

        goldenTest(
          "example_screen_error",
          fileName: "example_screen/error",
          builder: () => buildGoldenScreen(
            state: newGoldenScreenStateError(),
            delegate: delegate,
          ),
          constraints: GoldenDevices.iPhone17.constraints,
          pumpWidget: goldenTestPumpWidget,
        );
      });
    });
