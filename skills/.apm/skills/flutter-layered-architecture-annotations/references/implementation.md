# `@implementation`

具象実装を公開する package のバレル `library` に付与する。依存元を同一レイヤーの `@injection` に限定するための役割宣言。

## いつ付けるか

* `*_impl` など、interface の具象実装をまとめた package を作る・直すとき
* in-memory / 本番実装など、差し替え可能な実装 package の公開面を宣言するとき

## 付与先

* **バレル `library` のみ**（`lib/` 直下かつ `library;` あり）
* 型には付けない（`@Target({TargetKind.library})`）

## 必須併記

* なし
* **同じバレルに `@injection` を併記しない**

## 付与後に効く Lint

| Lint code | 要点 |
| --- | --- |
| `architecture_implementation_dependency` | この package への直接依存は、同一レイヤー名の `@injection` のみ許可。それ以外からの依存は WARNING |

検査は pubspec の `dependencies` / `dev_dependencies` 直接依存が対象。import だけの依存は `depend_on_referenced_packages` 側。

詳細は次の SKILL を正とする。

* `flutter-layered-architecture-linter-rule-architecture-implementation-dependency`
* （境界）`flutter-layered-architecture-linter-rule-architecture-layer-dependency`

## 推奨形

* interface package と実装 package を分ける
* 結線は同レイヤーの `@injection` package に集約する
* 実装 package 内の状態保持型には、必要なら `@stateful` / `@delegate` を型側で付ける

## 良い例

```dart
@implementation
library;

import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';

export 'src/add_todo_usecase_impl.dart';
export 'src/list_todos_usecase_impl.dart';
```

## 悪い例

```dart
@implementation
library;

// 別レイヤーや非 injection package の pubspec からこの package を dependencies に追加
// → architecture_implementation_dependency
```

```dart
@injection
@implementation // both → warning
library;
```

## DO NOT

* `@implementation` package を app や他レイヤーから直接 dependencies に足さない（injection 経由）
* interface 側バレルに `@implementation` を付けない
* `@injection` との併記で「どっちも」にしない
