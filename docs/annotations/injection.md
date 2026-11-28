# `@injection` (removed)

`@injection` has been **removed**. DI wiring packages are identified by a pubspec `name` that **ends with `_injection`** (e.g. `data_injection`).

* Dependency rules: [`architecture_implementation_dependency`](../linter-rules/architecture_implementation_dependency.md)
* Wiring patterns: `flutter-layered-architecture-design-dependency-injection` SKILL

Barrels use `library;` and exports only; do not declare package role via library annotations.