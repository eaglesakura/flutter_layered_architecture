import 'package:analyzer/error/error.dart' show DiagnosticSeverity;

/// アーキテクチャ違反として報告する Lint の重要度.
///
/// `@usecase` / `@delegate` / `@stateful` の規約違反は WARNING に揃える.
const architectureViolationSeverity = DiagnosticSeverity.WARNING;
