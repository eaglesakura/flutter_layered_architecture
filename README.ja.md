# Flutter Layered Architecture

Flutter Layered Architecture のプロジェクト導入をサポートするリポジトリである。

Analyzer プラグイン（`dart analyze` / IDE）・Runtime・SKILL の組み合わせで、レイヤード構成の導入と運用を支援する。

## 構成要素

| 要素 | 役割 |
| --- | --- |
| Analyzer プラグイン | レイヤー境界や依存方向などの規約を `dart analyze` / IDE で静的に検査する（`analysis_server_plugin`） |
| Runtime | 実行時にレイヤード構成を支えるライブラリを提供する |
| SKILL | Agent 向けの導入・運用手順を提供する |

## Analyzer プラグイン（linter）の導入

**ワークスペース／package ルート**の `analysis_options.yaml` に、トップレベルで `plugins:` を追加する（`analyzer:` 配下ではない。ネストした options では指定できない）:

```yaml
plugins:
  flutter_layered_architecture_lint:
    path: packages/lint
```

Dart 3.14+（Flutter 3.50+）が必要である。`plugins:` を変更したら IDE の Dart Analysis Server を再起動すること。

`flutter_layered_architecture_annotations` と併用する。本プラグインのルールはすべて warning rule として登録されているため、プラグイン有効時は**既定でオン**である。違反は **WARNING** として報告される。

[`docs/`](docs/) 配下のリファレンスは、Dart の linter rule ドキュメント（例: [always_declare_return_types](https://dart.dev/tools/linter-rules/always_declare_return_types)）に合わせている。短い要約、Details（BAD/GOOD）、Enable / Usage の順である。

レイヤー所属・依存方向・ファイル名キーワードなどの正本はワークスペース（または祖先）の `layered_architecture.yaml` である。スキーマと探索規則は [layered_architecture_yaml.ja.md](docs/layered_architecture_yaml.ja.md) を参照する。

### 個別ルールの有効・無効

プラグイン直下の `diagnostics:` でルール単位に切り替える。キーはルールコード（ドキュメントのファイル名／LintCode と同じ）である。

```yaml
plugins:
  flutter_layered_architecture_lint:
    path: packages/lint
    diagnostics:
      one_public_type_per_file: false
      public_type_file_name: false
      usecase_single_method: true
```

- `true` / `false` — そのルールを有効／無効にする
- `info` / `warning` / `error` — 有効にしたうえで重要度を指定する（analyzer が対応している場合）

`diagnostics:` を変更したら Analysis Server を再起動すること。

ルール自体は無効にせず、該当箇所だけ抑止する場合:

```dart
// ignore: flutter_layered_architecture_lint/one_public_type_per_file
// ignore_for_file: flutter_layered_architecture_lint/one_public_type_per_file
```

## 構成ファイル

| ファイル | ドキュメント |
| --- | --- |
| `layered_architecture.yaml` | [layered_architecture_yaml.ja.md](docs/layered_architecture_yaml.ja.md) |

## アノテーション

| アノテーション | ドキュメント |
| --- | --- |
| `@usecase` | [usecase.ja.md](docs/annotations/usecase.ja.md) |
| `@delegate` | [delegate.ja.md](docs/annotations/delegate.ja.md) |
| `@state` | [state.ja.md](docs/annotations/state.ja.md) |
| `@entity` | [entity.ja.md](docs/annotations/entity.ja.md) |
| `@stateful` | [stateful.ja.md](docs/annotations/stateful.ja.md) |
| `@viewModel` | [viewmodel.ja.md](docs/annotations/viewmodel.ja.md) |
| `@injection` | [injection.ja.md](docs/annotations/injection.ja.md) |
| `@implementation` | [implementation.ja.md](docs/annotations/implementation.ja.md) |

## Linter ルール

### Architecture layer

| ルール | ドキュメント |
| --- | --- |
| `architecture_layer_dependency` | [architecture_layer_dependency.ja.md](docs/linter-rules/architecture_layer_dependency.ja.md) |
| `architecture_implementation_dependency` | [architecture_implementation_dependency.ja.md](docs/linter-rules/architecture_implementation_dependency.ja.md) |

### File layout

| ルール | ドキュメント |
| --- | --- |
| `one_public_type_per_file` | [one_public_type_per_file.ja.md](docs/linter-rules/one_public_type_per_file.ja.md) |
| `public_type_file_name` | [public_type_file_name.ja.md](docs/linter-rules/public_type_file_name.ja.md) |
| `unexported_public_must_be_internal` | [unexported_public_must_be_internal.ja.md](docs/linter-rules/unexported_public_must_be_internal.ja.md) |

### `@usecase`

| ルール | ドキュメント |
| --- | --- |
| `usecase_single_method` | [usecase_single_method.ja.md](docs/linter-rules/usecase_single_method.ja.md) |
| `usecase_method_signature` | [usecase_method_signature.ja.md](docs/linter-rules/usecase_method_signature.ja.md) |
| `usecase_immutable` | [usecase_immutable.ja.md](docs/linter-rules/usecase_immutable.ja.md) |

### `@delegate`

| ルール | ドキュメント |
| --- | --- |
| `delegate_execute_method` | [delegate_execute_method.ja.md](docs/linter-rules/delegate_execute_method.ja.md) |
| `delegate_immutable` | [delegate_immutable.ja.md](docs/linter-rules/delegate_immutable.ja.md) |
| `delegate_internal` | [delegate_internal.ja.md](docs/linter-rules/delegate_internal.ja.md) |
| `delegate_no_nested_delegate` | [delegate_no_nested_delegate.ja.md](docs/linter-rules/delegate_no_nested_delegate.ja.md) |
| `delegate_no_usecase_instantiation` | [delegate_no_usecase_instantiation.ja.md](docs/linter-rules/delegate_no_usecase_instantiation.ja.md) |

### `@state` / `@entity`

| ルール | ドキュメント |
| --- | --- |
| `state_entity_freezed` | [state_entity_freezed.ja.md](docs/linter-rules/state_entity_freezed.ja.md) |
| `state_entity_internal` | [state_entity_internal.ja.md](docs/linter-rules/state_entity_internal.ja.md) |
| `state_entity_exclusive` | [state_entity_exclusive.ja.md](docs/linter-rules/state_entity_exclusive.ja.md) |
| `state_entity_required_parameters` | [state_entity_required_parameters.ja.md](docs/linter-rules/state_entity_required_parameters.ja.md) |
| `state_entity_no_named_factory` | [state_entity_no_named_factory.ja.md](docs/linter-rules/state_entity_no_named_factory.ja.md) |

### `@stateful`

| ルール | ドキュメント |
| --- | --- |
| `stateful_immutable` | [stateful_immutable.ja.md](docs/linter-rules/stateful_immutable.ja.md) |
| `stateful_has_mutable_state_stream` | [stateful_has_mutable_state_stream.ja.md](docs/linter-rules/stateful_has_mutable_state_stream.ja.md) |
| `stateful_closes_mutable_state_stream` | [stateful_closes_mutable_state_stream.ja.md](docs/linter-rules/stateful_closes_mutable_state_stream.ja.md) |
| `stateful_mutable_state_stream_state` | [stateful_mutable_state_stream_state.ja.md](docs/linter-rules/stateful_mutable_state_stream_state.ja.md) |
| `stateful_methods_use_delegate` | [stateful_methods_use_delegate.ja.md](docs/linter-rules/stateful_methods_use_delegate.ja.md) |

`@viewModel` はこれらの `@stateful` 検査も継承する。

### `@viewModel`

| ルール | ドキュメント |
| --- | --- |
| `viewmodel_internal` | [viewmodel_internal.ja.md](docs/linter-rules/viewmodel_internal.ja.md) |
| `viewmodel_has_entity_getter` | [viewmodel_has_entity_getter.ja.md](docs/linter-rules/viewmodel_has_entity_getter.ja.md) |
| `viewmodel_entity_annotated` | [viewmodel_entity_annotated.ja.md](docs/linter-rules/viewmodel_entity_annotated.ja.md) |
| `viewmodel_entity_differs_from_state` | [viewmodel_entity_differs_from_state.ja.md](docs/linter-rules/viewmodel_entity_differs_from_state.ja.md) |
| `viewmodel_on_method_names` | [viewmodel_on_method_names.ja.md](docs/linter-rules/viewmodel_on_method_names.ja.md) |

## APM SKILL の導入

本リポジトリルートは [APM (Agent Package Manager)](https://microsoft.github.io/apm/) パッケージである（`apm.yml` / `.apm/skills/`）。Agent 向けの workspace 把握・annotations / linter rule ガイドを、利用側プロジェクトへ入れる。

前提として APM CLI が必要である。未導入なら [Installation](https://microsoft.github.io/apm/getting-started/installation/) を参照する。

```bash
apm --version
```

利用側リポジトリのルートで、未初期化なら一度だけ初期化する:

```bash
apm init
```

その後、次のいずれかで本パッケージを追加する。本番ではタグ固定を推奨する: `eaglesakura/flutter_layered_architecture#v0.1.0`。

### `apm.yml` に記載してから install する

利用側の `apm.yml` を編集し、`dependencies.apm` に本パッケージを列挙する:

```yaml
name: my-app
version: 0.1.0
dependencies:
  apm:
    - eaglesakura/flutter_layered_architecture#v0.1.0
    # ローカル path（開発時）:
    # - ./path/to/flutter_layered_architecture
```

インストール（または `git clone` 後の復元）:

```bash
apm install
```

### `apm install` でパッケージを直接指定する

`apm install` にパッケージを渡す。APM が解決し、`apm.yml` / `apm.lock.yaml` を更新する:

```bash
# GitHub ショートハンド
apm install eaglesakura/flutter_layered_architecture

# タグで固定する場合（推奨）
apm install eaglesakura/flutter_layered_architecture#v0.1.0

# ローカル path（開発時）
apm install ./path/to/flutter_layered_architecture
```

### コミット対象

コミットするのは `apm.yml`・`apm.lock.yaml`・`.gitignore`（および自作の `.apm/`）までとする。`apm_modules/` はコミットしない。チームは `git clone` 後に `apm install` で復元する。

### 収録 SKILL

| 種別 | SKILL |
| --- | --- |
| Workspace | `flutter-layered-architecture-workspace` |
| Coding rules | `flutter-layered-architecture-coding-rules` |
| Design | `flutter-layered-architecture-design-usecase` / `flutter-layered-architecture-design-repository` / `flutter-layered-architecture-design-screen-mvvm` / `flutter-layered-architecture-design-screen-navigation` |
| Annotations | `flutter-layered-architecture-annotations` |
| Architecture layer | `flutter-layered-architecture-resolve-package-layer` |
| Linter rules | `flutter-layered-architecture-linter-rule-{rule}`（診断コードの `_` を `-` に置換） |

linter rule のカテゴリとルール一覧は [AGENTS.md](AGENTS.md) を参照する。

## 推奨ライブラリ

| カテゴリ | 推奨ライブラリ |
| --- | --- |
| Dependency Injection | [Riverpod](https://pub.dev/packages/riverpod) |
| UI 構築 | [Riverpod](https://pub.dev/packages/flutter_riverpod) / [Hooks](https://pub.dev/packages/flutter_hooks)（[hooks_riverpod](https://pub.dev/packages/hooks_riverpod)） |
| 状態管理 | [state_stream](https://pub.dev/packages/state_stream) / [state_stream_riverpod](https://pub.dev/packages/state_stream_riverpod) |

## リポジトリ構成

```text
flutter_layered_architecture/
├── pubspec.yaml              # Dart workspace ルート
├── analysis_options.yaml     # 共有静的解析設定
├── apm.yml                   # APM パッケージ定義
├── docs/                     # 構成ファイル / アノテーション / linter-rule リファレンス
│   ├── layered_architecture_yaml.ja.md
│   ├── annotations/
│   └── linter-rules/
├── layered_architecture.yaml # アーキテクチャレイヤー定義（正本）
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
└── .apm/skills/              # Agent 向け SKILL
```
