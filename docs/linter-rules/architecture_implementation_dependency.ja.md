# architecture_implementation_dependency

`_injection` 以外、または別レイヤーの package が、`_impl` で終わる package に依存すると警告する。

レイヤー所属に使う `layered_architecture.yaml` のスキーマは [layered_architecture_yaml.ja.md](../layered_architecture_yaml.ja.md) を参照する。

## Details

DO `_impl` package への依存を、同一レイヤーの `_injection` package のみに限定する。役割は **pubspec の `name`** のサフィックスのみで判定する（`name.endsWith('_injection')` / `name.endsWith('_impl')`）。バレルや library annotation は見ない。

* `_injection` を `_impl` より先に判定する（例: `foo_impl_injection` → DI 用）
* 名前に `_impl` / `_injection` を含むだけでは役割にならない（`endsWith` のみ）
* いずれの `path_prefix` にも属さない package、および定義不在・不正はスキップする（定義まわりは `architecture_layer_dependency` の担当）
* 検査対象は `dependencies` と `dev_dependencies` の直接依存名のみである

Severity は WARNING である。

### rules.architecture_implementation_dependency.ignore

移行中や特殊事情のため、特定 package 名だけ **`_impl` 依存検査**をスキップできる。セマンティクスは [`architecture_layer_dependency`](architecture_layer_dependency.ja.md) の `rules.architecture_layer_dependency.ignore` と同型である（検査対象が level ではなく `_impl` 依存可否である点のみ異なる）。

```yaml
rules:
  architecture_implementation_dependency:
    ignore:
      - infra_example_ignore
```

* 要素は pubspec の package 名。**完全一致**のみ（部分一致・正規表現なし。trim しない）
* 一致した **依存元** の `_impl` 依存検査のみスキップする。定義スコープ診断は ignore していても報告する
* 依存先が ignore に載っていても、依存元が ignore に無ければ通常どおり検査する
* 未記載・空リスト・親キー欠落は「設定なし」と同等
* 形式不正、または `package_config.json` で解決できない名前が 1 件でもあれば WARNING（記述エラー）とし、ignore スキップは適用しない

BAD:

```yaml
# example_app（同一レイヤーの _injection ではない）が data_repository_todo_impl に依存
dependencies:
  data_repository_todo_impl:
    path: ../data/repository/todo/_impl
```

GOOD:

```yaml
# data_injection/pubspec.yaml（name: data_injection）— 同一 data レイヤーの _injection → _impl
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
