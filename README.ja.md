# Flutter Layered Architecture

Flutter Layered Architecture のプロジェクト導入をサポートするリポジトリである。

Analyzer プラグイン（`dart analyze` / IDE）・Runtime・SKILL の組み合わせで、レイヤード構成の導入と運用を支援する。

## 構成要素

| 要素 | 役割 |
| --- | --- |
| Analyzer プラグイン | レイヤー境界や依存方向などの規約を `dart analyze` / IDE で静的に検査する（`analysis_server_plugin`） |
| Runtime | 実行時にレイヤード構成を支えるライブラリを提供する |
| SKILL | Agent 向けの導入・運用手順を提供する |

## Analyzer プラグインの有効化

ワークスペースルートの `analysis_options.yaml`:

```yaml
plugins:
  flutter_layered_architecture_lint:
    path: packages/lint
```

Dart 3.14+（Flutter 3.50+）が必要。`plugins:` を変更したら IDE の Dart Analysis Server を再起動すること。

## APM SKILL の導入

`skills/` は [APM (Agent Package Manager)](https://microsoft.github.io/apm/) パッケージである。Agent 向けの annotations / linter rule ガイドを、利用側プロジェクトへ次の手順で入れる。

前提として APM CLI が必要である。未導入なら [Installation](https://microsoft.github.io/apm/getting-started/installation/) を参照する。

```bash
apm --version
```

利用側リポジトリのルートで:

```bash
# 未初期化なら一度だけ
apm init

# skills サブディレクトリを仮想パッケージとして追加
apm install eaglesakura/flutter_layered_architecture/skills
```

タグで固定する場合（推奨）:

```bash
apm install eaglesakura/flutter_layered_architecture/skills#v0.1.0
```

このリポジトリをローカル path 参照する場合:

```bash
apm install ./path/to/flutter_layered_architecture/skills
```

コミットするのは `apm.yml`・`apm.lock.yaml`・`.gitignore`（および自作の `.apm/`）までとする。`apm_modules/` はコミットしない。チームは `git clone` 後に `apm install` で復元する。

収録 SKILL の一覧は [`skills/README.md`](skills/README.md) を参照する。

## 推奨ライブラリ

| カテゴリ | 推奨ライブラリ |
| --- | --- |
| Dependency Injection | [Riverpod](https://pub.dev/packages/riverpod) |
| UI 構築 | [Riverpod](https://pub.dev/packages/flutter_riverpod) / [Hooks](https://pub.dev/packages/flutter_hooks)（[hooks_riverpod](https://pub.dev/packages/hooks_riverpod)） |

## リポジトリ構成

```text
flutter_layered_architecture/
├── pubspec.yaml              # Dart workspace ルート
├── analysis_options.yaml     # 共有静的解析設定
├── packages/                 # 公開・利用する Dart/Flutter package
│   ├── annotations/          # flutter_layered_architecture_annotations
│   └── lint/                 # flutter_layered_architecture_lint
├── example/                  # Layered Architecture TODO サンプル（Web）
│   ├── app/                  # example_app
│   ├── foundation/dependency_injection/ # foundation_dependency_injection
│   ├── domain/todo/          # domain_todo
│   ├── data/repository/todo/ # data_repository_todo (+ _impl)
│   ├── usecase/todo/         # usecase_todo (+ _impl)
│   └── screen/feature/todo_list/ # screen_feature_todo_list
└── skills/                   # 本リポジトリ連動の SKILL
```
