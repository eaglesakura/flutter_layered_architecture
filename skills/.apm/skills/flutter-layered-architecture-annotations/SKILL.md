---
name: flutter-layered-architecture-annotations
description: >-
  Flutter Layered Architecture のアノテーション付与ガイド。
  `@usecase` / `@delegate` / `@stateful` / `@viewModel` / `@injection` /
  `@implementation` のどれを・どこに・何と併記して付けるかを決めるときに必ず使う。
  Usecase・Delegate・ViewModel・Repository 実装の新規作成、バレル library の役割宣言、
  「annotation を付ける」「lint が効くようにする」「injection / implementation」でもロードする。
  個別診断コードの深い修正手順だけなら対応する
  `flutter-layered-architecture-linter-rule-*` を使う。file_layout だけの話では使わない。
---
# Flutter Layered Architecture / Annotations

`flutter_layered_architecture_annotations` のアノテーションを、役割に合わせて正しく付与する。
付与すると `flutter_layered_architecture_lint` が構造を WARNING で検査する。
各ルールの詳細・抑制コメントは、対応する `flutter-layered-architecture-linter-rule-*` SKILL を正とする。

## いつ使うか

* 型やバレル `library` にどのアノテーションを付けるか決めるとき
* Usecase / Delegate / Stateful / ViewModel / Injection / Implementation を新規作成・改修するとき
* lint を効かせるために annotation を足す／付け替えるとき

## いつ使わないか

* 個別診断コード（例: `usecase_single_method`）の深い修正だけ → 対応する `linter-rule-*`
* ファイル分割・公開 API・バレル export だけ（annotation 無し） → `one_public_type_per_file` 等の file_layout 系
* レイヤー所属・`path_prefix` / `level` だけ → `architecture_layer_dependency`

## 作業手順

1. 対象の役割を下の対応表で決める
2. 該当する `references/` を **1 本だけ**読む（複数役割なら役割ごとに繰り返す）
3. import・付与位置・必須併記を満たして付与する
4. 付与後に効く lint 一覧を満たすよう型／package を整える
5. 診断が残ったら、対応する `flutter-layered-architecture-linter-rule-*` をロードする

## アノテーション対応表

| アノテーション | 付与先 | 主な用途 | 詳細 |
| --- | --- | --- | --- |
| `@usecase` | 型 | 1 操作の Usecase IF / 実装 | [references/usecase.md](./references/usecase.md) |
| `@delegate` | 型 | 単一処理の切り出し（`execute`） | [references/delegate.md](./references/delegate.md) |
| `@stateful` | 型 | `MutableStateStream` を持つ状態保持型 | [references/stateful.md](./references/stateful.md) |
| `@viewModel` | 型 | 画面 ViewModel（`@stateful` 制約を継承） | [references/view-model.md](./references/view-model.md) |
| `@injection` | バレル `library` | DI 結線専用 package | [references/injection.md](./references/injection.md) |
| `@implementation` | バレル `library` | 具象実装を公開する package | [references/implementation.md](./references/implementation.md) |

## 共通ルール

* import は次で揃える（top-level 定数 `@usecase` 等を使う）:

```dart
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
```

* `@internal` が必要な場合は `package:meta/meta.dart` も import する
* 診断の重要度はすべて **WARNING**
* 抑制は `// ignore: flutter_layered_architecture_lint/<rule_code>`（詳細は各 linter-rule SKILL）
* バレルは `lib/` 直下かつ `library;`（または名前付き `library`）があるファイル。`lib/src/` はバレルではない

## `@viewModel` と `@stateful`

* 画面向け ViewModel は **`@viewModel` を付ける**（`@stateful` を二重に書く必要はない）
* `@viewModel` は `@stateful` の制約を引き継ぐ
* Repository 実装など、画面以外で `MutableStateStream` を持つ型は `@stateful` を使う

## Annotation を増やすとき（メンテ）

今後アノテーションが増えたら、この形式を崩さず次を行う。

1. `packages/annotations` に定数と型を追加する
2. 本 SKILL の対応表に 1 行追加する
3. `references/<name>.md` を新規追加する（既存と同型の見出し）
4. 連動する `flutter-layered-architecture-linter-rule-*` があれば「連動 Lint」に列挙する

## 関連

* アノテーション package: `flutter_layered_architecture_annotations`
* Lint プラグイン: `flutter_layered_architecture_lint`（`analysis_options.yaml` の top-level `plugins:`）
* ルール単位 SKILL: `skills/.apm/skills/flutter-layered-architecture-linter-rule-*`
