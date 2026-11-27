# architecture_implementation_dependency

Warns when a non-`@injection` or cross-layer package depends on `@implementation` barrels.

## Details

DO allow only same-layer `@injection` packages to depend on `@implementation` packages. Role is read from barrel files under `lib/` that declare `library;` (name-based `@injection` / `@implementation`; URI is not checked). `lib/src/` is ignored.

If both annotations appear on barrels in the same package, the rule reports a warning and stops the dependency check for that package. Packages outside every `path_prefix`, or with a missing/invalid layer definition, are skipped (`architecture_layer_dependency` covers definition issues). Inspection covers `dependencies` and `dev_dependencies` direct names only.

Severity is WARNING.

Related annotations: `@injection`, `@implementation` (on barrel `library`).

BAD:

```yaml
# example_app (not same-layer @injection) depends on data_repository_todo_impl
dependencies:
  data_repository_todo_impl:
    path: ../data/repository/todo/_impl
```

```dart
@injection
@implementation
library;
```

GOOD:

```dart
// data_injection barrel
@injection
library;

export 'src/data_injection_bindings.dart';
```

```dart
// data_repository_todo_impl barrel (same data layer)
@implementation
library;

export 'src/in_memory_todo_repository.dart';
```

```yaml
# data_injection/pubspec.yaml — same-layer @injection → @implementation
dependencies:
  data_repository_todo_impl:
    path: ../repository/todo/_impl
```

## Enable

This rule ships with the `flutter_layered_architecture_lint` analyzer plugin. Enable the plugin in the workspace root `analysis_options.yaml`:

```yaml
plugins:
  flutter_layered_architecture_lint:
    path: packages/lint
```

Requires Dart 3.14+ (Flutter 3.50+). After changing `plugins:`, restart the Dart Analysis Server.

## Suppress

```dart
// ignore: flutter_layered_architecture_lint/architecture_implementation_dependency
```
