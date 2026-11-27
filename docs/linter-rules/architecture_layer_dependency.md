# architecture_layer_dependency

Warns when a package under `layered_architecture.yaml` depends on a higher architecture layer.

## Details

DO keep pubspec direct dependencies flowing downward or sideways by layer `level`. The plugin uses the nearest `layered_architecture.yaml` found upward from the package root. Each layer has a `path_prefix` (relative to the YAML directory) and an optional `level`. When both packages have a `level`, `dep.level > self.level` is a warning (`dep.level <= self.level` is allowed, including same level).

Only packages under some `path_prefix` are checked. Packages outside every `path_prefix` (for example this lint package) are skipped. Inspection covers `dependencies` and `dev_dependencies` direct names only; transitive deps are out of scope. Import-only deps are covered by `depend_on_referenced_packages`, not this rule.

Also warns for a missing or invalid YAML, overlapping `path_prefix` values, and a package matching multiple layers. Unused layer entries with no packages are allowed. Layers without `level` may connect to any layer (no level comparison). Severity is WARNING for all of these cases.

#### rules.architecture_layer_dependency.ignore

Skip **dependency-direction** checks for listed package names during migration or special cases.

* `ignore` is a list of pubspec package names. Matching is **exact** only (no glob/regex; no trimming).
* Only the **depending** package (self) skips level checks when its name matches. Definition-scope diagnostics (missing/invalid YAML, overlapping `path_prefix`, etc.) still report even when ignored.
* Depending on an ignored package does **not** skip checks for a non-ignored depender.
* Missing/`[]`/absent parent keys mean “no ignore”.
* Malformed entries, or any name not resolvable in `package_config.json`, yield a **WARNING** (config error) and disable ignore skipping.

GOOD `layered_architecture.yaml` (excerpt):

```yaml
layers:
  - usecase:
      level: 4
      path_prefix: example/usecase
  - data:
      level: 4
      path_prefix: example/data
  - domain:
      level: 2
      path_prefix: example/domain
  - testing:
      # no level → may connect to any layer
      path_prefix: example/testing
```

* `usecase_*` → `data_*` (both level 4): allowed
* `screen_*` (6) → `domain_*` (2): allowed
* `testing_*` (no level) ↔ any layer: allowed

BAD:

```yaml
# domain (level 2) must not depend on usecase (level 4)
# in example/domain/todo/pubspec.yaml:
dependencies:
  usecase_todo:
    path: ../../usecase/todo
```

```yaml
# overlapping path_prefix (pre-check warning)
layers:
  - data:
      level: 4
      path_prefix: example/data
  - data_repo:
      level: 4
      path_prefix: example/data/repository
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
// ignore: flutter_layered_architecture_lint/architecture_layer_dependency
```
