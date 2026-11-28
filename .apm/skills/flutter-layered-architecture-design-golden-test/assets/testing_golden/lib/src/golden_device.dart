import "package:flutter/widgets.dart";

import "golden_devices.dart" show GoldenDevices;

/// Golden Test で模擬する端末の画面寸法。
///
/// [name] は識別・レポート用。[width] / [height] は portrait の論理ピクセル。
/// 定義済み一覧は [GoldenDevices] を参照する。
final class GoldenDevice {
  /// 表示名。
  final String name;

  /// portrait 向きの論理ピクセル幅。
  final double width;

  /// portrait 向きの論理ピクセル高さ。
  final double height;

  /// [name]、[width]、[height] で端末寸法を指定する。
  const GoldenDevice({
    required this.name,
    required this.width,
    required this.height,
  });

  /// Golden Test のルートに渡す画面サイズ制約。
  BoxConstraints get constraints => BoxConstraints(
        maxWidth: width,
        maxHeight: height,
      );
}
