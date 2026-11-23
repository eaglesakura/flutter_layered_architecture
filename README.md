# Flutter Layered Architecture

A repository that helps you adopt Flutter Layered Architecture in your projects.

It combines a Custom Linter, Runtime libraries, and SKILLs to support introducing and operating a layered structure.

## Components

| Component | Role |
| --- | --- |
| Custom Linter | Statically checks conventions such as layer boundaries and dependency direction |
| Runtime | Provides libraries that support layered architecture at runtime |
| SKILL | Provides agent-oriented guides for adoption and day-to-day use |

## Repository layout

```text
flutter_layered_architecture/
├── pubspec.yaml              # Dart workspace root
├── analysis_options.yaml     # Shared static analysis settings
├── packages/                 # Published / consumed Dart/Flutter packages
└── skills/                   # SKILLs tied to this repository
```
