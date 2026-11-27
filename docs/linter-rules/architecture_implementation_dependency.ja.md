# architecture_implementation_dependency

`@injection` 以外、または別レイヤーの package が `@implementation` バレルに依存すると警告する。

## Details

DO `@implementation` package への依存を、同一レイヤーの `@injection` package のみに限定する。役割は `lib/` 直下かつ `library;` があるバレルから読む（名前ベースの `@injection` / `@implementation`。URI は見ない）。`lib/src/` は見ない。

同一 package のバレルに両方のアノテーションがある場合は warning を出し、その package の依存検査を停止する。どの `path_prefix` にも属さない package、および定義不在・不正はスキップする（定義まわりは `architecture_layer_dependency` の担当）。検査対象は `dependencies` と `dev_dependencies` の直接依存名のみである。

Severity は WARNING である。

関連アノテーション: `@injection`、`@implementation`（バレルの `library` に付与）。

BAD:

```yaml
# example_app（同一レイヤーの @injection ではない）が data_repository_todo_impl に依存
dependencies:
  data_repository_todo_impl:
    path: ../data/repository/todo/_impl
```

```dart
@injection
@implementation
library;
```

GOOD:

```dart
// data_injection バレル
@injection
library;

export 'src/data_injection_bindings.dart';
```

```dart
// data_repository_todo_impl バレル（同一 data レイヤー）
@implementation
library;

export 'src/in_memory_todo_repository.dart';
```

```yaml
# data_injection/pubspec.yaml — 同一レイヤーの @injection → @implementation
dependencies:
  data_repository_todo_impl:
    path: ../repository/todo/_impl
```

## Enable

本ルールは `flutter_layered_architecture_lint` analyzer プラグインに含まれる。ワークスペースルートの `analysis_options.yaml` でプラグインを有効化する:

```yaml
plugins:
  flutter_layered_architecture_lint:
    path: packages/lint
```

Dart 3.14+（Flutter 3.50+）が必要である。`plugins:` を変更したら Dart Analysis Server を再起動する。

## Suppress

```dart
// ignore: flutter_layered_architecture_lint/architecture_implementation_dependency
```
