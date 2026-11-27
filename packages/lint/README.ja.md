# flutter_layered_architecture_lint

Flutter Layered Architecture の規約向け Analyzer プラグインである。

Dart 3.14+（Flutter 3.50+）が必要である。
[`flutter_layered_architecture_annotations`](https://pub.dev/packages/flutter_layered_architecture_annotations)
と併用する。

アーキテクチャおよびアノテーション違反は **WARNING** として報告される。プラグイン有効時、ルールは**既定でオン**である。

## Getting started

```yaml
dependencies:
  flutter_layered_architecture_annotations: ^0.1.0

dev_dependencies:
  flutter_layered_architecture_lint: ^0.1.0
```

**ワークスペース／package ルート**の `analysis_options.yaml` に、トップレベルで `plugins:` を追加する（`analyzer:` 配下ではない。ネストした options では指定できない）:

```yaml
plugins:
  flutter_layered_architecture_lint: ^0.1.0
```

`plugins:` を変更したら IDE の Dart Analysis Server を再起動すること。

### 個別ルールの有効・無効

```yaml
plugins:
  flutter_layered_architecture_lint:
    diagnostics:
      one_public_type_per_file: false
      public_type_file_name: false
      usecase_single_method: true
```

- `true` / `false` — そのルールを有効／無効にする
- `info` / `warning` / `error` — 有効にしたうえで重要度を指定する（analyzer が対応している場合）

該当箇所だけ抑止する場合:

```dart
// ignore: flutter_layered_architecture_lint/one_public_type_per_file
// ignore_for_file: flutter_layered_architecture_lint/one_public_type_per_file
```

## Rules

ルール一覧と詳細は [README.md](README.md) およびリポジトリの `docs/linter-rules/` を参照する。

主なカテゴリ:

- Architecture layer（`architecture_layer_dependency` など）
- File layout（`one_public_type_per_file` など）
- `@usecase` / `@delegate` / `@stateful` / `@viewModel` / `@state` / `@entity`

任意設定は最寄りの `layered_architecture.yaml` で行う（レイヤー `path_prefix`、ignore、ファイル名 keywords など）。

## Additional information

- Repository: <https://github.com/eaglesakura/flutter_layered_architecture>
- English README: [README.md](README.md)
