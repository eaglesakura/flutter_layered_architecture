# Flutter Layered Architecture

A repository that helps you adopt Flutter Layered Architecture in your projects.

It combines an analyzer plugin (`dart analyze` / IDE), Runtime libraries, and SKILLs to support introducing and operating a layered structure.

## Components

| Component | Role |
| --- | --- |
| Analyzer plugin | Statically checks conventions such as layer boundaries and dependency direction via `dart analyze` / the IDE (`analysis_server_plugin`) |
| Runtime | Provides libraries that support layered architecture at runtime |
| SKILL | Provides agent-oriented guides for adoption and day-to-day use |

## Enabling the analyzer plugin (linter)

Add a top-level `plugins:` section in the **workspace / package root** `analysis_options.yaml` (not under `analyzer:`, and not in a nested options file):

```yaml
plugins:
  flutter_layered_architecture_lint:
    path: packages/lint
```

Requires Dart 3.14+ (Flutter 3.50+). After changing `plugins:`, restart the Dart Analysis Server in the IDE.

Pair with `flutter_layered_architecture_annotations`. All rules in this plugin are registered as warning rules, so they are **on by default** when the plugin is enabled. Violations are reported as **WARNING**.

Reference pages under [`docs/`](docs/) follow the Dart linter rule docs style (for example [always_declare_return_types](https://dart.dev/tools/linter-rules/always_declare_return_types)): short summary, Details with BAD/GOOD, then Enable / Usage.

Layer membership, dependency direction, file-name keywords, and related settings live in the workspace (or an ancestor) `layered_architecture.yaml`. Schema and discovery rules are documented in [layered_architecture_yaml.md](docs/layered_architecture_yaml.md).

### Enable or disable individual rules

Toggle rules under `diagnostics:` for the plugin. Use the rule code (same as the docs file name / LintCode):

```yaml
plugins:
  flutter_layered_architecture_lint:
    path: packages/lint
    diagnostics:
      one_public_type_per_file: false
      public_type_file_name: false
      usecase_single_method: true
```

- `true` / `false` — enable or disable that rule
- `info` / `warning` / `error` — enable with that severity (when supported by the analyzer)

Restart the Analysis Server after changing `diagnostics:`.

To suppress a finding in code (not disable the rule globally):

```dart
// ignore: flutter_layered_architecture_lint/one_public_type_per_file
// ignore_for_file: flutter_layered_architecture_lint/one_public_type_per_file
```

## Configuration files

| File | Docs |
| --- | --- |
| `layered_architecture.yaml` | [layered_architecture_yaml.md](docs/layered_architecture_yaml.md) |

## Annotations

| Annotation | Docs |
| --- | --- |
| `@usecase` | [usecase.md](docs/annotations/usecase.md) |
| `@delegate` | [delegate.md](docs/annotations/delegate.md) |
| `@state` | [state.md](docs/annotations/state.md) |
| `@entity` | [entity.md](docs/annotations/entity.md) |
| `@stateful` | [stateful.md](docs/annotations/stateful.md) |
| `@viewModel` | [viewmodel.md](docs/annotations/viewmodel.md) |
| `@injection` | [injection.md](docs/annotations/injection.md) |
| `@implementation` | [implementation.md](docs/annotations/implementation.md) |

## Linter rules

### Architecture layer

| Rule | Docs |
| --- | --- |
| `architecture_layer_dependency` | [architecture_layer_dependency.md](docs/linter-rules/architecture_layer_dependency.md) |
| `architecture_implementation_dependency` | [architecture_implementation_dependency.md](docs/linter-rules/architecture_implementation_dependency.md) |

### File layout

| Rule | Docs |
| --- | --- |
| `one_public_type_per_file` | [one_public_type_per_file.md](docs/linter-rules/one_public_type_per_file.md) |
| `public_type_file_name` | [public_type_file_name.md](docs/linter-rules/public_type_file_name.md) |
| `unexported_public_must_be_internal` | [unexported_public_must_be_internal.md](docs/linter-rules/unexported_public_must_be_internal.md) |

### Riverpod Provider

| Rule | Docs |
| --- | --- |
| `provider_static_final` | [provider_static_final.md](docs/linter-rules/provider_static_final.md) |
| `provider_ref_watch` | [provider_ref_watch.md](docs/linter-rules/provider_ref_watch.md) |
| `provider_dependencies` | [provider_dependencies.md](docs/linter-rules/provider_dependencies.md) |

### `@usecase`

| Rule | Docs |
| --- | --- |
| `usecase_single_method` | [usecase_single_method.md](docs/linter-rules/usecase_single_method.md) |
| `usecase_method_signature` | [usecase_method_signature.md](docs/linter-rules/usecase_method_signature.md) |
| `usecase_immutable` | [usecase_immutable.md](docs/linter-rules/usecase_immutable.md) |

### `@delegate`

| Rule | Docs |
| --- | --- |
| `delegate_execute_method` | [delegate_execute_method.md](docs/linter-rules/delegate_execute_method.md) |
| `delegate_immutable` | [delegate_immutable.md](docs/linter-rules/delegate_immutable.md) |
| `delegate_internal` | [delegate_internal.md](docs/linter-rules/delegate_internal.md) |
| `delegate_no_nested_delegate` | [delegate_no_nested_delegate.md](docs/linter-rules/delegate_no_nested_delegate.md) |
| `delegate_no_usecase_instantiation` | [delegate_no_usecase_instantiation.md](docs/linter-rules/delegate_no_usecase_instantiation.md) |

### `@state` / `@entity`

| Rule | Docs |
| --- | --- |
| `state_entity_freezed` | [state_entity_freezed.md](docs/linter-rules/state_entity_freezed.md) |
| `state_entity_internal` | [state_entity_internal.md](docs/linter-rules/state_entity_internal.md) |
| `state_entity_exclusive` | [state_entity_exclusive.md](docs/linter-rules/state_entity_exclusive.md) |
| `state_entity_required_parameters` | [state_entity_required_parameters.md](docs/linter-rules/state_entity_required_parameters.md) |
| `state_entity_no_named_factory` | [state_entity_no_named_factory.md](docs/linter-rules/state_entity_no_named_factory.md) |

### `@stateful`

| Rule | Docs |
| --- | --- |
| `stateful_immutable` | [stateful_immutable.md](docs/linter-rules/stateful_immutable.md) |
| `stateful_has_mutable_state_stream` | [stateful_has_mutable_state_stream.md](docs/linter-rules/stateful_has_mutable_state_stream.md) |
| `stateful_closes_mutable_state_stream` | [stateful_closes_mutable_state_stream.md](docs/linter-rules/stateful_closes_mutable_state_stream.md) |
| `stateful_mutable_state_stream_state` | [stateful_mutable_state_stream_state.md](docs/linter-rules/stateful_mutable_state_stream_state.md) |
| `stateful_methods_use_delegate` | [stateful_methods_use_delegate.md](docs/linter-rules/stateful_methods_use_delegate.md) |

`@viewModel` also inherits these `@stateful` checks.

### `@viewModel`

| Rule | Docs |
| --- | --- |
| `viewmodel_internal` | [viewmodel_internal.md](docs/linter-rules/viewmodel_internal.md) |
| `viewmodel_has_entity_getter` | [viewmodel_has_entity_getter.md](docs/linter-rules/viewmodel_has_entity_getter.md) |
| `viewmodel_entity_annotated` | [viewmodel_entity_annotated.md](docs/linter-rules/viewmodel_entity_annotated.md) |
| `viewmodel_entity_differs_from_state` | [viewmodel_entity_differs_from_state.md](docs/linter-rules/viewmodel_entity_differs_from_state.md) |
| `viewmodel_on_method_names` | [viewmodel_on_method_names.md](docs/linter-rules/viewmodel_on_method_names.md) |

## Installing APM SKILLs

This repository root is an [APM (Agent Package Manager)](https://microsoft.github.io/apm/) package (`apm.yml` / `.apm/skills/`). Use it to bring agent-facing workspace, annotation, and linter-rule guides into a consuming project.

APM CLI is required. If it is not installed yet, see [Installation](https://microsoft.github.io/apm/getting-started/installation/).

```bash
apm --version
```

From the consuming repository root, initialize once if needed:

```bash
apm init
```

Then add this package with either approach below. Pin a tag in production (recommended): `eaglesakura/flutter_layered_architecture#v0.1.0`.

### Declare in `apm.yml`, then install

Edit the consuming project's `apm.yml` and list the package under `dependencies.apm`:

```yaml
name: my-app
version: 0.1.0
dependencies:
  apm:
    - eaglesakura/flutter_layered_architecture#v0.1.0
    # Local path (development):
    # - ./path/to/flutter_layered_architecture
```

Install (or restore after `git clone`):

```bash
apm install
```

### Install with a direct package argument

Pass the package to `apm install`. APM resolves it and updates `apm.yml` / `apm.lock.yaml`:

```bash
# GitHub shorthand
apm install eaglesakura/flutter_layered_architecture

# Pin a tag (recommended)
apm install eaglesakura/flutter_layered_architecture#v0.1.0

# Local path (development)
apm install ./path/to/flutter_layered_architecture
```

### What to commit

Commit `apm.yml`, `apm.lock.yaml`, and `.gitignore` (plus any authored `.apm/`). Do not commit `apm_modules/`. Teammates restore dependencies with `apm install` after `git clone`.

### Shipped SKILLs

| Kind | SKILL |
| --- | --- |
| Workspace | `flutter-layered-architecture-workspace` |
| Coding rules | `flutter-layered-architecture-coding-rules` |
| Dependencies | `flutter-layered-architecture-dependencies` |
| Design | `flutter-layered-architecture-design-usecase` / `flutter-layered-architecture-design-repository` / `flutter-layered-architecture-design-dependency-injection` / `flutter-layered-architecture-design-screen-mvvm` / `flutter-layered-architecture-design-screen-navigation` / `flutter-layered-architecture-design-test` |
| Annotations | `flutter-layered-architecture-annotations` |
| Architecture layer | `flutter-layered-architecture-resolve-package-layer` |
| Linter rules | `flutter-layered-architecture-linter-rule-{rule}` (rule code with `_` replaced by `-`) |

For linter-rule categories and the full rule list, see [AGENTS.md](AGENTS.md).

## Recommended libraries

| Category | Recommended libraries |
| --- | --- |
| Dependency Injection | [Riverpod](https://pub.dev/packages/riverpod) |
| UI construction | [Riverpod](https://pub.dev/packages/flutter_riverpod) / [Hooks](https://pub.dev/packages/flutter_hooks) ([hooks_riverpod](https://pub.dev/packages/hooks_riverpod)) |
| State management | [state_stream](https://pub.dev/packages/state_stream) / [state_stream_riverpod](https://pub.dev/packages/state_stream_riverpod) |
| Navigation | [go_router](https://pub.dev/packages/go_router) |

## Repository layout

```text
flutter_layered_architecture/
├── pubspec.yaml              # Dart workspace root
├── analysis_options.yaml     # Shared static analysis settings
├── apm.yml                   # APM package definition
├── docs/                     # Config / annotation / linter-rule reference pages
│   ├── layered_architecture_yaml.md
│   ├── annotations/
│   └── linter-rules/
├── layered_architecture.yaml # Architecture layer definition (canonical)
├── packages/                 # Published / consumed Dart/Flutter packages
│   ├── annotations/          # flutter_layered_architecture_annotations
│   └── lint/                 # flutter_layered_architecture_lint
├── example/                  # Layered Architecture TODO sample (Web)
│   ├── app/                  # example_app
│   ├── foundation/dependency_injection/ # foundation_dependency_injection
│   ├── domain/todo/          # domain_todo
│   ├── data/repository/todo/ # data_repository_todo (+ _impl)
│   ├── usecase/todo/         # usecase_todo (+ _impl)
│   └── screen/feature/todo_list/ # screen_feature_todo_list
└── .apm/skills/              # Agent-facing SKILLs
```
