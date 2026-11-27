---
name: flutter-layered-architecture-linter-rule-architecture-layer-dependency
description: >-
  Flutter Layered Architecture の linter rule `architecture_layer_dependency`。
  layered_architecture.yaml に基づき、package のレイヤー所属と依存方向（level）を検査する。
  レイヤー境界・path_prefix・依存逆転、診断 `architecture_layer_dependency` の修正では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# アーキテクチャレイヤー依存（`architecture_layer_dependency`）

`layered_architecture.yaml` のレイヤー定義に従い、**所属レイヤー内の package** について
pubspec の直接依存の方向を検査する。

## いつ使うか

* `architecture_layer_dependency` 診断の修正・抑制判断
* レイヤー追加・`path_prefix` / `level` の変更
* package の `dependencies` / `dev_dependencies` 追加時の境界確認

## 定義ファイル

* ファイル名: `layered_architecture.yaml`（正本の例: `@flutter_layered_architecture/layered_architecture.yaml`）
* 探索: 検査対象 package のディレクトリから親へ辿り、**最初に見つかった** `layered_architecture.yaml` を適用する
* ルートまで存在しなければ **warning**
* `path_prefix` は、その定義ファイルがあるディレクトリからの相対パスとする
* 配下に package が無いレイヤー定義（未使用レイヤー）は **許可**（将来予約）

## ルールが検証すること

### 検査対象

* いずれかの `path_prefix` に所属する package **のみ**（例: `example/domain/...`）
* アーキテクチャ外（`packages/lint`、外部 SDK・ツール等）は **スキップ**
* 検査する依存は `dependencies` と `dev_dependencies` の **直接依存名のみ**

### 所属

* レイヤー所属は、各レイヤーの `path_prefix` 配下の package
* package の実パス解決は `.dart_tool/package_config.json`（package 名 → root URI）で行う
* 配下判定は path separator を OS 差含め正規化したうえで行う（パス区切り境界を尊重する）
* 定義読み込み後、所属 package を解析する前に `path_prefix` の **重複・包括を事前チェック** し **warning**（定義ファイルあたり 1 回）
* **1 package が複数レイヤーにマッチすることは許可しない**。マッチした場合は **warning** とし、当該 package の依存方向検査は行わない（定義の `path_prefix` を直す）
* 依存先 package が複数レイヤーにマッチした場合も **warning**（その依存エッジの level 比較は行わない）

### 依存方向

* 依存元・依存先の双方に `level` があり、かつ双方の所属が単一のとき、依存先の `level` が依存元の `level` **以下**（同レベル含む、`dep.level <= self.level`）でなければ **warning**
* `level` は optional。`level` 未記載のレイヤーは、任意のレイヤーと双方向に接続できる（level 比較の対象外）
* 片方のみ `level` がある依存は level 比較の対象外（warning にしない）
* いずれの `path_prefix` にも属さない依存先は比較しない

### ignore

移行中や特殊事情のため、特定 package 名だけ **依存方向検査**をスキップできる。

* `rules.architecture_layer_dependency.ignore` は pubspec の package 名（文字列）のリスト。**完全一致**のみ（部分一致・正規表現なし。trim しない）
* 一致した **依存元** の level 違反検査のみスキップする。定義不在・YAML 不正・`path_prefix` 重複／包括などの定義スコープ診断は、ignore していても報告する
* 依存先が ignore に載っていても、依存元が ignore に無ければ通常どおり検査する
* `ignore` 未記載・空リスト・親キー欠落は「設定なし」と同等
* 形式不正、または `package_config.json` で解決できない名前が 1 件でもあれば **WARNING（記述エラー）** とし、ignore によるスキップは適用しない

### 重要度

本ルールが出す診断は **すべて warning**（定義不在・YAML 不正・path_prefix 事前チェック・複数レイヤー所属・level 違反・ignore 記述エラー）。
必要なら `analysis_options.yaml` の `analyzer.errors` で個別に error 昇格する。
既存の `@usecase` / `@delegate` 等の architecture 違反と同様 WARNING に揃える。

| 状況 | severity |
| --- | --- |
| 定義ファイルがルートまで見つからない | warning |
| 定義ファイルがパース不能／最小スキーマ違反 | warning（依存方向検査は行わない） |
| `path_prefix` の重複・包括（事前チェック） | warning |
| package（または依存先）が複数レイヤーにマッチ | warning（所属不定のため当該の level 比較は行わない） |
| level 制約を破る依存 | warning |
| ignore の形式不正または未解決 package 名 | warning（ignore スキップは無効） |

## スコープ外（別手段）

| 関心 | 扱い |
| --- | --- |
| pubspec に書かず import のみ | 標準 linter [`depend_on_referenced_packages`](https://dart.dev/tools/linter-rules/depend_on_referenced_packages)。本リポジトリでは `analysis_options.yaml` の `analyzer.errors.depend_on_referenced_packages: error` で error 昇格済み |
| 同レベル間の循環 | 許容（`level` 以下判定で単純化。循環専用チェックはしない） |
| 間接（transitive）依存 | 対象外 |
| 実装 package（`_impl` 等）の上位からの露出 | 別 linter ルールの担当。本ルールの実装スコープ外 |

## 良い例

```yaml
# layered_architecture.yaml（抜粋）
layers:
  - usecase:
      level: 4
      path_prefix: example/usecase
  - data:
      level: 4
      path_prefix: example/data
  - testing:
      # level なし → 任意レイヤーと接続可
      path_prefix: example/testing
```

* `usecase_*` → `data_*`（同 level 4）: 許可
* `screen_*`（6）→ `domain_*`（2）: 許可
* `testing_*`（level なし）↔ 任意レイヤー: 許可
* `view` / `infra` など package が無いレイヤー定義のみ: 許可（未使用レイヤー）

## 悪い例

* `domain_*`（2）の `dependencies` に `usecase_*`（4）→ `architecture_layer_dependency`（warning）
* `path_prefix: example/data` と `path_prefix: example/data/repository` を別レイヤーで併記 → 包括として warning（事前チェック）。配下 package は複数レイヤーマッチとしても warning
* 親を辿っても `layered_architecture.yaml` が無い → warning

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/architecture_layer_dependency
```

## 関連

* package 所属レイヤーの解決: `flutter-layered-architecture-resolve-package-layer`
* 定義ファイル: `@flutter_layered_architecture/layered_architecture.yaml`
* YAML スキーマ: `@flutter_layered_architecture/docs/layered_architecture_yaml.ja.md`
* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* 標準ルール（import と pubspec の対応）: [`depend_on_referenced_packages`](https://dart.dev/tools/linter-rules/depend_on_referenced_packages)
