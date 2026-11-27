# flutter_layered_architecture_annotations

Annotations for Flutter Layered Architecture conventions.

Use together with
[`flutter_layered_architecture_lint`](https://pub.dev/packages/flutter_layered_architecture_lint)
so `dart analyze` / the IDE can validate structure and layer boundaries.

## Features

| Annotation | Role |
| --- | --- |
| `@usecase` | Marks a Usecase type (one public operation) |
| `@delegate` | Marks a Delegate type (`execute` entry point) |
| `@state` | Marks a state model (typically Freezed + `@internal`) |
| `@entity` | Marks an entity / view model payload (typically Freezed + `@internal`) |
| `@stateful` | Marks a type that owns `MutableStateStream` |
| `@viewModel` | Marks a ViewModel (`@stateful` + `entity` getter) |
| `@injection` | Marks a DI / wiring package barrel `library` |
| `@implementation` | Marks an implementation package barrel `library` |

## Getting started

```yaml
dependencies:
  flutter_layered_architecture_annotations: ^0.1.0
```

```dart
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
```

## Usage

```dart
@usecase
abstract interface class ListTodosUsecase {
  const ListTodosUsecase();

  Future<List<Todo>> execute(ListTodosRequest request);
}
```

Pair with the analyzer plugin for static checks. See the repository
[README](https://github.com/eaglesakura/flutter_layered_architecture) and
`docs/annotations/` for full references.

## Additional information

- Repository: <https://github.com/eaglesakura/flutter_layered_architecture>
- Japanese README: [README.ja.md](README.ja.md)
