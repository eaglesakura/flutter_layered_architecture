import 'package:meta/meta_meta.dart';

/// `@implementation` 記法用の定数インスタンス.
///
/// Example:
/// ```dart
/// @implementation
/// library;
///
/// export 'src/in_memory_todo_repository.dart';
/// ```
const implementation = Implementation();

/// 実装用 package のバレル `library` に付与するアノテーション.
///
/// interface の具象実装を公開する package の役割を宣言し、
/// `flutter_layered_architecture_lint` が依存元を検証できるようにする.
///
/// Example:
/// ```dart
/// @implementation
/// library;
///
/// export 'src/repository_impl.dart';
/// ```
@Target({TargetKind.library})
final class Implementation {
  /// [Implementation] を生成する.
  const Implementation();
}
