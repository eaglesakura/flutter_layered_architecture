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
