import 'package:meta/meta_meta.dart';

/// `@injection` 記法用の定数インスタンス.
///
/// Example:
/// ```dart
/// @injection
/// library;
///
/// export 'src/data_injection_bindings.dart';
/// ```
const injection = Injection();

/// 注入用 package のバレル `library` に付与するアノテーション.
///
/// DI 結線専用 package の役割を宣言し、
/// `flutter_layered_architecture_lint` が `@implementation` への依存を検証できるようにする.
///
/// Example:
/// ```dart
/// @injection
/// library;
///
/// export 'src/bindings.dart';
/// ```
@Target({TargetKind.library})
final class Injection {
  /// [Injection] を生成する.
  const Injection();
}
