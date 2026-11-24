import 'package:analyzer/error/error.dart' show DiagnosticSeverity;
import 'package:meta/meta.dart';

/// アーキテクチャ違反として報告する Lint の重要度.
///
/// `@usecase` / `@delegate` / `@stateful` / `@viewModel` の規約違反は WARNING に揃える.
@internal
const architectureViolationSeverity = DiagnosticSeverity.WARNING;
