# `@implementation` (removed)

`@implementation` has been **removed**. Implementation packages are identified by a pubspec `name` that **ends with `_impl`** (e.g. `data_repository_todo_impl`).

* Dependency rules: [`architecture_implementation_dependency`](../linter-rules/architecture_implementation_dependency.md)
* Implementation providers and wiring: `flutter-layered-architecture-design-dependency-injection` SKILL

Barrels use `library;` and exports only; do not declare package role via library annotations.