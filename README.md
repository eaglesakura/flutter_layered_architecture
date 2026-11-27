# Flutter Layered Architecture

A repository that helps you adopt Flutter Layered Architecture in your projects.

It combines an analyzer plugin (`dart analyze` / IDE), Runtime libraries, and SKILLs to support introducing and operating a layered structure.

## Components

| Component | Role |
| --- | --- |
| Analyzer plugin | Statically checks conventions such as layer boundaries and dependency direction via `dart analyze` / the IDE (`analysis_server_plugin`) |
| Runtime | Provides libraries that support layered architecture at runtime |
| SKILL | Provides agent-oriented guides for adoption and day-to-day use |

## Enabling the analyzer plugin

In the workspace root `analysis_options.yaml`:

```yaml
plugins:
  flutter_layered_architecture_lint:
    path: packages/lint
```

Requires Dart 3.14+ (Flutter 3.50+). After changing `plugins:`, restart the Dart Analysis Server in the IDE.

Pair with `flutter_layered_architecture_annotations`. Violations are reported as **WARNING**.

Reference pages under [`docs/`](docs/) follow the Dart linter rule docs style (for example [always_declare_return_types](https://dart.dev/tools/linter-rules/always_declare_return_types)): short summary, Details with BAD/GOOD, then Enable / Usage.

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

### `@state` / `@entity` (gate A)

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

`skills/` is an [APM (Agent Package Manager)](https://microsoft.github.io/apm/) package. Use it to bring agent-facing annotation and linter-rule guides into a consuming project.

APM CLI is required. If it is not installed yet, see [Installation](https://microsoft.github.io/apm/getting-started/installation/).

```bash
apm --version
```

From the consuming repository root:

```bash
# Once, if the project is not initialized yet
apm init

# Add the skills subdirectory as a virtual package
apm install eaglesakura/flutter_layered_architecture/skills
```

To pin a tag (recommended):

```bash
apm install eaglesakura/flutter_layered_architecture/skills#v0.1.0
```

To reference this repository via a local path:

```bash
apm install ./path/to/flutter_layered_architecture/skills
```

Commit `apm.yml`, `apm.lock.yaml`, and `.gitignore` (plus any authored `.apm/`). Do not commit `apm_modules/`. Teammates restore dependencies with `apm install` after `git clone`.

For the list of shipped SKILLs, see [`skills/README.md`](skills/README.md).

## Recommended libraries

| Category | Recommended libraries |
| --- | --- |
| Dependency Injection | [Riverpod](https://pub.dev/packages/riverpod) |
| UI construction | [Riverpod](https://pub.dev/packages/flutter_riverpod) / [Hooks](https://pub.dev/packages/flutter_hooks) ([hooks_riverpod](https://pub.dev/packages/hooks_riverpod)) |

## Repository layout

```text
flutter_layered_architecture/
├── pubspec.yaml              # Dart workspace root
├── analysis_options.yaml     # Shared static analysis settings
├── docs/                     # Annotation / linter-rule reference pages
│   ├── annotations/
│   └── linter-rules/
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
└── skills/                   # SKILLs tied to this repository
```
