import "golden_device.dart";

/// Golden Test 用の端末寸法カタログ（参考実装）。
///
/// プロジェクトで対象デバイスを増減してよい。viewport は各 OS の仕様に合わせる。
final class GoldenDevices {
  /// iPhone 17（402×874）。代表端末の例。
  static const iPhone17 = GoldenDevice(
    name: "iPhone 17",
    width: 402,
    height: 874,
  );

  /// iPhone SE 3（375×667）。小さい画面の例。
  static const iPhoneSe3 = GoldenDevice(
    name: "iPhone SE 3",
    width: 375,
    height: 667,
  );

  /// Pixel 10（412×923）。Android 代表の例。
  static const pixel10 = GoldenDevice(
    name: "Pixel 10",
    width: 412,
    height: 923,
  );

  const GoldenDevices._();
}
