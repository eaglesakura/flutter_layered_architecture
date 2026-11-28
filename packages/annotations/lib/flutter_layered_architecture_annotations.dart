/// Flutter Layered Architecture 向けアノテーションを公開する.
///
/// 静的検査は `flutter_layered_architecture_lint` と組み合わせて使う.
/// DI / 実装 package の役割は pubspec 名の `_injection` / `_impl` サフィックスで宣言する
/// （旧 `@injection` / `@implementation` は廃止）.
library;

export 'src/delegate.dart';
export 'src/entity.dart';
export 'src/state.dart';
export 'src/stateful.dart';
export 'src/usecase.dart';
export 'src/viewmodel.dart';