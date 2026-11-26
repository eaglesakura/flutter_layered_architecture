/// Flutter Layered Architecture 向けアノテーションを公開する.
///
/// 静的検査は `flutter_layered_architecture_lint` と組み合わせて使う.
/// バレル `library` 向けの `@injection` / `@implementation` もここから公開する.
library;

export 'src/delegate.dart';
export 'src/implementation.dart';
export 'src/injection.dart';
export 'src/stateful.dart';
export 'src/usecase.dart';
export 'src/viewmodel.dart';
