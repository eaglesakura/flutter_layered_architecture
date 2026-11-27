# layered_architecture.yaml

## Overview

`layered_architecture.yaml` is the source of truth for **architecture layer definitions and rule settings** in Flutter Layered Architecture.

* The analyzer plugin (`flutter_layered_architecture_lint`) reads it to resolve package layer membership, dependency direction, file-name keywords, and related checks
* Discovery walks from the inspected package root up parent directories and uses the **first** file found
* Canonical example: [`layered_architecture.yaml`](../layered_architecture.yaml) at the repository root

Related linter rules:

* [`architecture_layer_dependency`](linter-rules/architecture_layer_dependency.md) — layer membership and dependency direction (`level`)
* [`architecture_implementation_dependency`](linter-rules/architecture_implementation_dependency.md) — restricts deps on `@implementation` (membership still comes from this YAML’s `path_prefix`)
* [`public_type_file_name`](linter-rules/public_type_file_name.md) — `rules.public_type_file_name.keywords`

## File discovery

Starting from the package root (`pubspec.yaml` directory), walk parents and use the first `layered_architecture.yaml`.

* If none exists up to the filesystem root, layer-dependency rules report a **warning** (missing definition)
* `path_prefix` is relative to the **directory that contains** that definition file
* Package real paths come from `.dart_tool/package_config.json` (package name → root URI)
* Path comparison normalizes separators and respects path-boundary matching

## Top-level schema

The top level must be a map. Recognized keys:

| Key | Required | Description |
| --- | --- | --- |
| `layers` | Yes (when layer checks run) | List of layer definitions |
| `rules` | No | Per-rule settings |

```yaml
layers:
  - domain:
      level: 2
      description: |
        Domain layer.
      path_prefix: example/domain
  - testing:
      description: |
        Unit-test support.
      path_prefix: example/testing

rules:
  architecture_layer_dependency:
    ignore:
      - infra_example_ignore
  public_type_file_name:
    keywords:
      UseCase: usecase
      ViewModel: viewmodel
```

The snippet above is excerpted from the repository canonical file. See the full [`layered_architecture.yaml`](../layered_architecture.yaml).

## layers

`layers` is a list. Each entry must be a **single-key map** (key = layer name, value = config map).

### Layer entry shape

```yaml
layers:
  - <layer_name>:
      path_prefix: <relative path>   # required, non-empty string
      level: <positive int>          # optional
      description: <string>          # optional (human docs; parser ignores)
```

| Field | Required | Type / constraints | Description |
| --- | --- | --- | --- |
| (key) layer name | Yes | string | Identifier used in diagnostics (e.g. `usecase`, `domain`) |
| `path_prefix` | Yes | non-empty string | Relative to the YAML directory. Packages under (or equal to) this path belong to the layer |
| `level` | No | positive integer (`> 0`) | Used for dependency-direction comparison. If omitted, the layer may connect to any layer (no level compare) |
| `description` | No | string | Documentation only; the lint parser does not read it |

`level` of `0`, negative, or non-integer is a parse failure (warning). Missing/empty `path_prefix` is likewise a parse failure.

### Notes on layers

* Benefit: directory layout and layer boundaries stay mechanical, so dependency inversions can be caught statically
* Caveat: overlapping or nested `path_prefix` values warn in a pre-check. A package matching multiple layers is not allowed
* Scope: only packages under some `path_prefix` are layer-checked. Packages outside every prefix are treated as out of architecture and skipped
* Exceptions: unused layer entries with no packages are allowed as future reservations. Layers without `level` are excluded from level comparison

### Membership

1. Discover the definition file (see “File discovery”)
2. Resolve the package real path via `package_config.json`
3. Resolve each `path_prefix` against the definition directory and test whether the package root is under (or equal to) it
4. At most one match. Multiple matches warn and skip dependency-direction checks for that package

### Dependency direction (`level`)

When both packages have a single layer membership and both have `level`, the dependency’s `level` must be **less than or equal to** the depender (`dep.level <= self.level`, same level allowed). Violations are warnings from [`architecture_layer_dependency`](linter-rules/architecture_layer_dependency.md).

* Edges where only one side has `level` are not compared
* Dependencies outside every `path_prefix` are not compared
* Same-level cycles are not detected by this YAML / that rule

## rules

`rules` is an optional map. Currently recognized sub-settings:

### rules.architecture_layer_dependency.ignore

Skip **dependency-direction (`level`) checks** for listed package names.

```yaml
rules:
  architecture_layer_dependency:
    ignore:
      - infra_example_ignore
```

* Entries are pubspec package names. Matching is **exact** only (no glob/regex; no trimming)
* Only the **depending** package (self) skips level checks when its name matches
* Definition-scope diagnostics (missing/invalid YAML, overlapping `path_prefix`, etc.) still report even when ignored
* Depending on an ignored package does **not** skip checks for a non-ignored depender
* Missing / `[]` / absent parent keys mean “no ignore”
* Malformed entries, or any name not resolvable in `package_config.json`, yield a WARNING (config error) and disable ignore skipping

See [`architecture_layer_dependency`](linter-rules/architecture_layer_dependency.md) for details.

### rules.public_type_file_name.keywords

Map CamelCase type-name segments to expected file-name tokens.

```yaml
rules:
  public_type_file_name:
    keywords:
      UseCase: usecase
      ViewModel: viewmodel
```

* Key = CamelCase segment to replace (e.g. `UseCase`); value = file-name token (e.g. `usecase`)
* Applied in YAML declaration order; earlier keys win on overlap
* Matching is case-sensitive (`UseCase` does not match type segment `Usecase`)
* Missing or empty `rules` / `keywords` keeps the default PascalCase→snake conversion
* Invalid or skipped entries yield an empty keyword list (no WARNING for missing keywords)

Example: with `UseCase: usecase`, type `AddTodoUseCase` expects `add_todo_usecase.dart` (without keywords: `add_todo_use_case.dart`).

See [`public_type_file_name`](linter-rules/public_type_file_name.md) for details.

## Knowledge base

### DO: keep path_prefix values sibling, not nested

* Cut layer boundaries at sibling directories; do not put parent and child under different layers

```yaml
# DO: sibling prefixes
layers:
  - data:
      level: 4
      path_prefix: example/data
  - usecase:
      level: 4
      path_prefix: example/usecase
```

### DO NOT: declare a nested path_prefix as another layer

* Reason: the pre-check warns on containment, and packages under the child may also match multiple layers

```yaml
# DO NOT: example/data contains example/data/repository
layers:
  - data:
      level: 4
      path_prefix: example/data
  - data_repo:
      level: 4
      path_prefix: example/data/repository
```

### DO: omit level for freely connecting layers

* Test support packages that may connect to any layer should omit `level`

```yaml
layers:
  - testing:
      path_prefix: example/testing
```

### DO NOT: set level to 0, negative, or non-integer

* Reason: parse failure; dependency-direction checks do not run

## See also

* Canonical file: [`layered_architecture.yaml`](../layered_architecture.yaml)
* Rule details (dependency direction): [`architecture_layer_dependency`](linter-rules/architecture_layer_dependency.md)
* Rule details (implementation deps): [`architecture_implementation_dependency`](linter-rules/architecture_implementation_dependency.md)
* Rule details (file names): [`public_type_file_name`](linter-rules/public_type_file_name.md)
