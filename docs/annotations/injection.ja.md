# @injection

DI 結線専用 package のバレル `library` に付与し、`@implementation` package への依存が許可される側の役割を宣言するアノテーションである。

## Details

DO バレル `library`（`lib/` 直下かつ `library;` あり）にのみ `@injection` を付与する。対象は library のみ（`@Target({TargetKind.library})`）であり、型には付けない。同一バレルに `@implementation` を併記してはならない（both は warning となり、依存検査が止まる）。レイヤー所属そのものは `layered_architecture.yaml` に基づく `architecture_layer_dependency` が別途検査する。本アノテーションは「実装 package を誰が依存してよいか」の役割印であり、同一レイヤー名の `@injection` のみが `@implementation` へ依存できる。

関連 lint の Severity: WARNING。

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

付与先: バレル `library` のみ。

## Related linter rules

* [architecture_implementation_dependency](../linter-rules/architecture_implementation_dependency.ja.md)
* [architecture_layer_dependency](../linter-rules/architecture_layer_dependency.ja.md)
