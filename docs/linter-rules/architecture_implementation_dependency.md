# architecture_implementation_dependency

Warns when a non-`_injection` or cross-layer package depends on a package whose pubspec `name` ends with `_impl`.

For the `layered_architecture.yaml` schema used for layer membership, see [layered_architecture_yaml.md](../layered_architecture_yaml.md).

## Details

DO allow only same-layer `_injection` packages to depend on `_impl` packages. Role comes **only** from the pubspec `name` suffix (`name.endsWith('_injection')` / `name.endsWith('_impl')`). Barrel files and library annotations are not read.

* `_injection` is checked before `_impl` (e.g. `foo_impl_injection` → DI role)
* Substrings alone do not assign a role (only `endsWith`)
* Packages outside every `path_prefix`, or with a missing/invalid layer definition, are skipped (`architecture_layer_dependency` covers definition issues)
* Inspection covers `dependencies` and `dev_dependencies` direct names only

Severity is WARNING.

### rules.architecture_implementation_dependency.ignore

Skip **`_impl` dependency checks** for listed package names during migration or special cases. Semantics match `rules.architecture_layer_dependency.ignore` in [`architecture_layer_dependency`](architecture_layer_dependency.md); only the inspected edge differs (implementation exposure instead of `level`).

```yaml
rules:
  architecture_implementation_dependency:
    ignore:
      - infra_example_ignore
```

* Entries are pubspec package names. Matching is **exact** only (no glob/regex; no trimming)
* Only the **depending** package (self) skips `_impl` dependency checks when its name matches. Definition-scope diagnostics still report when ignored
* Depending on an ignored package does **not** skip checks for a non-ignored depender
* Missing / `[]` / absent parent keys mean “no ignore”
* Malformed entries, or any name not resolvable in `package_config.json`, yield a WARNING (config error) and disable ignore skipping

BAD:

```yaml
# example_app (not same-layer _injection) depends on data_repository_todo_impl
dependencies:
  data_repository_todo_impl:
    path: ../data/repository/todo/_impl
```

GOOD:

```yaml
# data_injection/pubspec.yaml (name: data_injection) — same data layer _injection → _impl
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