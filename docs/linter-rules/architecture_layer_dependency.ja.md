# architecture_layer_dependency

`layered_architecture.yaml` 配下の package が、より高いアーキテクチャレイヤーに依存すると警告する。

## Details

DO pubspec の直接依存を、レイヤー `level` に沿って下方向または同レベルに保つ。プラグインは package root から親へ辿り、最初に見つかった `layered_architecture.yaml` を使う。各レイヤーは `path_prefix`（YAML 所在ディレクトリからの相対パス）と optional の `level` を持つ。双方に `level` があるとき、`dep.level > self.level` は warning である（`dep.level <= self.level`、同レベル含む、が許可）。

いずれかの `path_prefix` に所属する package のみ検査する。どの `path_prefix` にも属さない package（例: 本 lint package）はスキップする。検査対象は `dependencies` と `dev_dependencies` の直接依存名のみであり、間接依存は対象外である。import のみの依存は `depend_on_referenced_packages` の担当であり、本ルールの対象外である。

定義不在・YAML 不正・`path_prefix` の重複・包括、および複数レイヤーへのマッチも warning する。package が無い未使用レイヤー定義は許可する。`level` 未記載のレイヤーは任意レイヤーと接続できる（level 比較対象外）。これらの Severity はいずれも WARNING である。

#### rules.architecture_layer_dependency.ignore

移行中や特殊事情のため、特定 package 名だけ **依存方向検査**をスキップできる。

* `ignore` は pubspec の package 名（文字列）のリスト。**完全一致**のみ（部分一致・正規表現なし。trim しない）
* 一致した **依存元** の level 違反検査のみスキップする。定義不在・YAML 不正・`path_prefix` 重複／包括などの定義スコープ診断は、ignore していても報告する
* 依存先が ignore に載っていても、依存元が ignore に無ければ通常どおり検査する
* `ignore` 未記載・空リスト・親キー欠落は「設定なし」と同等
* 形式不正、または `package_config.json` で解決できない名前が 1 件でもあれば **WARNING（記述エラー）** とし、ignore によるスキップは適用しない

GOOD な `layered_architecture.yaml`（抜粋）:

```yaml
layers:
  - usecase:
      level: 4
      path_prefix: example/usecase
  - data:
      level: 4
      path_prefix: example/data
  - domain:
      level: 2
      path_prefix: example/domain
  - testing:
      # level なし → 任意レイヤーと接続可
      path_prefix: example/testing
```

* `usecase_*` → `data_*`（ともに level 4）: 許可
* `screen_*`（6）→ `domain_*`（2）: 許可
* `testing_*`（level なし）↔ 任意レイヤー: 許可

BAD:

```yaml
# domain (level 2) が usecase (level 4) に依存してはならない
# example/domain/todo/pubspec.yaml:
dependencies:
  usecase_todo:
    path: ../../usecase/todo
```

```yaml
# path_prefix の包括（事前チェック warning）
layers:
  - data:
      level: 4
      path_prefix: example/data
  - data_repo:
      level: 4
      path_prefix: example/data/repository
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
// ignore: flutter_layered_architecture_lint/architecture_layer_dependency
```
