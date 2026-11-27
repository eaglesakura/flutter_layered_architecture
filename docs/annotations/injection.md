# @injection

Marks the barrel `library` of a DI-wiring package so lint can treat it as the allowed depender on `@implementation` packages.

## Details

DO attach `@injection` only to a barrel `library` (`lib/` root file with a `library;` directive). The target is library-only (`@Target({TargetKind.library})`); do not attach it to types. Do not also attach `@implementation` on the same barrel (both yields a warning and stops dependency checks). Layer membership itself is enforced separately by `architecture_layer_dependency` via `layered_architecture.yaml`. This annotation declares which packages may depend on concrete implementation packages: same-layer `@injection` only.

Severity of related lint checks: WARNING.

BAD:

```dart
@injection
@implementation
library;
```

GOOD:

```dart
@injection
library;

import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';

export 'src/usecase_injection_bindings.dart';
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
