# @implementation

Marks the barrel `library` of a concrete-implementation package so lint can restrict direct dependents to same-layer `@injection` packages.

## Details

DO attach `@implementation` only to a barrel `library` (`lib/` root file with a `library;` directive). The target is library-only (`@Target({TargetKind.library})`); do not attach it to types. Do not also attach `@injection` on the same barrel. Direct `dependencies` / `dev_dependencies` on this package are allowed only from a same-layer `@injection` package; other dependers are WARNING. Layer boundary direction is separately enforced by `architecture_layer_dependency`. Import-only usage without a pubspec dependency is covered by `depend_on_referenced_packages`, not this rule.

Severity of related lint checks: WARNING.

BAD:

```dart
@injection
@implementation
library;
```

GOOD:

```dart
@implementation
library;

import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';

export 'src/add_todo_usecase_impl.dart';
export 'src/list_todos_usecase_impl.dart';
```

## Usage

Import:

```dart
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
```

Attach to: barrel `library` only.

## Related linter rules

* [architecture_implementation_dependency](../linter-rules/architecture_implementation_dependency.md)
* [architecture_layer_dependency](../linter-rules/architecture_layer_dependency.md)
