# architecture_unit_test_package_dependency

Warns when an architecture-layer package depends directly on a unit-test package (`*_test`) via `dependencies` or `dev_dependencies`.

For the `layered_architecture.yaml` schema used for layer membership, see [layered_architecture_yaml.md](../layered_architecture_yaml.md). Operational conventions (naming, black-box testing) live in `flutter-layered-architecture-design-test`.

## Details

DO keep unit-test packages (`in-layer` and pubspec `name.endsWith('_test')`) as **leaves** in the dependency graph. Only packages that belong to a single `path_prefix` are inspected as dependents. Inspection covers `dependencies` and `dev_dependencies` direct names only; `dependency_overrides` and transitive dependencies are out of scope.

Out-of-architecture dependents, missing/invalid definitions, and ambiguous membership of the dependent are skipped (definition diagnostics belong to `architecture_layer_dependency`). Dependents on packages that only `endsWith('_testing')` or use a `testing_` prefix are out of scope for this rule. Out-of-architecture `*_test` names are not treated as unit-test packages.

Severity is WARNING.

BAD:

```yaml
# domain_todo (in-layer) depends on usecase_todo_test
dependencies:
  usecase_todo_test:
    path: ../usecase/todo/_test
```

```yaml
# domain_todo lists *_test under dev_dependencies (also WARNING)
dev_dependencies:
  domain_todo_test:
    path: ./_test
```

```yaml
# leaf violation: domain_todo_test → other_feature_test
dependencies:
  other_feature_test:
    path: ../other/_test
```

GOOD:

```yaml
# Production packages do not list *_test. *_testing / testing_* are out of scope
dependencies:
  domain_todo:
    path: ../domain/todo
dev_dependencies:
  test: any
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
// ignore: flutter_layered_architecture_lint/architecture_unit_test_package_dependency
```
