# @implementation

具象実装を公開する package のバレル `library` に付与し、依存元を同一レイヤーの `@injection` に限定するための役割を宣言するアノテーションである。

## Details

DO バレル `library`（`lib/` 直下かつ `library;` あり）にのみ `@implementation` を付与する。対象は library のみ（`@Target({TargetKind.library})`）であり、型には付けない。同一バレルに `@injection` を併記してはならない。この package への直接依存（pubspec の `dependencies` / `dev_dependencies`）は、同一レイヤー名の `@injection` のみ許可され、それ以外からの依存は WARNING である。レイヤー境界の向きは `architecture_layer_dependency` が別途検査する。pubspec 依存なしの import のみは `depend_on_referenced_packages` 側の対象である。

関連 lint の Severity: WARNING。

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

付与先: バレル `library` のみ。

## Related linter rules

* [architecture_implementation_dependency](../linter-rules/architecture_implementation_dependency.ja.md)
* [architecture_layer_dependency](../linter-rules/architecture_layer_dependency.ja.md)
