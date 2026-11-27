# flutter_layered_architecture_annotations

Flutter Layered Architecture の規約向けアノテーションを提供する。

[`flutter_layered_architecture_lint`](https://pub.dev/packages/flutter_layered_architecture_lint)
と組み合わせて使い、`dart analyze` / IDE で構造やレイヤー境界を検証する。

## Features

| アノテーション | 役割 |
| --- | --- |
| `@usecase` | Usecase 型を示す（公開操作は1つ） |
| `@delegate` | Delegate 型を示す（`execute` 入口） |
| `@state` | state モデルを示す（通常は Freezed + `@internal`） |
| `@entity` | entity / ViewModel 向けペイロードを示す（通常は Freezed + `@internal`） |
| `@stateful` | `MutableStateStream` を持つ型を示す |
| `@viewModel` | ViewModel を示す（`@stateful` + `entity` getter） |
| `@injection` | DI / 結線用 package のバレル `library` を示す |
| `@implementation` | 実装 package のバレル `library` を示す |

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

静的検査は analyzer プラグインと併用する。詳細はリポジトリの
[README.ja.md](https://github.com/eaglesakura/flutter_layered_architecture/blob/main/README.ja.md)
および `docs/annotations/` を参照する。

## Additional information

- Repository: <https://github.com/eaglesakura/flutter_layered_architecture>
- English README: [README.md](README.md)
