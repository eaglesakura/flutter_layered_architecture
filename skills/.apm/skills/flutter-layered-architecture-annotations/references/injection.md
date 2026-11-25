# `@injection`

DI 結線専用 package のバレル `library` に付与する。`@implementation` package への依存が許可される側の役割宣言。

## いつ付けるか

* レイヤー内の injection package（例: `data/injection`, `usecase/injection`）を作る・直すとき
* 具象実装 package を pubspec から参照して Provider 結線する package の役割を明示するとき

## 付与先

* **バレル `library` のみ**（`lib/` 直下かつ `library;` あり）
* 型には付けない（`@Target({TargetKind.library})`）

## 必須併記

* なし
* **同じバレルに `@implementation` を併記しない**（both は warning になり、依存検査が止まる）

## 付与後に効く Lint

| Lint code | 要点 |
| --- | --- |
| `architecture_implementation_dependency` | `@implementation`（または both）への依存は、同一レイヤー名の `@injection` のみ許可 |

レイヤー所属そのものは `architecture_layer_dependency`（`layered_architecture.yaml`）が別途検査する。本アノテーションは「実装 package を誰が依存してよいか」の役割印。

詳細は次の SKILL を正とする。

* `flutter-layered-architecture-linter-rule-architecture-implementation-dependency`
* （境界）`flutter-layered-architecture-linter-rule-architecture-layer-dependency`

## 推奨形

* package は結線（bindings / Provider override）だけを公開する
* バレルは `@injection` + `library;` + 必要な `export`

## 良い例

```dart
@injection
library;

import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';

export 'src/usecase_injection_bindings.dart';
```

アノテーションは `library` の直前（または library ディレクティブに付く形）で、import より前に置く実例が多い。

## 悪い例

```dart
@injection
@implementation // both → warning、依存検査停止
library;
```

```dart
// 非 injection package が @implementation package に依存
// → architecture_implementation_dependency
```

## DO NOT

* interface 公開 package や app 本体に `@injection` を付けて実装依存を正当化しようとしない（役割が違う）
* `@injection` と `@implementation` を同一バレルに混在させない
* `lib/src/` のファイルに付けてもバレル判定されない
