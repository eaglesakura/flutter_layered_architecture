# `@flutter_layered_architecture/`

*このファイルのディレクトリが、 `@flutter_layered_architecture` の参照で解決されるルートディレクトリである*

## 重要ファイル構成

```text
@flutter_layered_architecture/
├── README.md                 # プロジェクト概要（英語）
├── README.ja.md              # プロジェクト概要（日本語）
├── pubspec.yaml              # Dart workspace ルート
├── analysis_options.yaml     # 共有静的解析設定
├── layered_architecture.yaml # アーキテクチャレイヤー定義（正本）
├── apm.yml                   # APM パッケージ定義（リポジトリルートが APM パッケージ）
├── docs/                     # 構成ファイル / アノテーション / linter-rule リファレンス
│   ├── layered_architecture_yaml.ja.md  # YAML スキーマ仕様（日本語）
│   ├── layered_architecture_yaml.md     # YAML スキーマ仕様（英語）
│   ├── annotations/          # アノテーションリファレンス
│   └── linter-rules/         # linter ルールリファレンス
├── packages/                 # 公開・利用する Dart/Flutter package
│   ├── annotations/          # flutter_layered_architecture_annotations
│   └── lint/                 # flutter_layered_architecture_lint
├── example/                  # Layered Architecture TODO サンプル（Web）
│   ├── app/                  # example_app
│   ├── foundation/dependency_injection/ # foundation_dependency_injection
│   ├── domain/todo/          # domain_todo
│   ├── data/repository/todo/ # data_repository_todo (+ _impl)
│   ├── data/injection/       # data_injection
│   ├── usecase/todo/         # usecase_todo (+ _impl)
│   ├── usecase/injection/    # usecase_injection
│   └── screen/feature/todo_list/ # screen_feature_todo_list
└── .apm/skills/              # Agent 向け SKILL（workspace / design-* / annotations / resolve / linter rule）
```

## APM SKILL

`flutter_layered_architecture_lint` / `flutter_layered_architecture_annotations`、
dart workspace 把握、Usecase / Repository / Screen MVVM 設計向け SKILL 集。
リポジトリルートの `apm.yml` が APM パッケージ定義である。

```text
.apm/skills/
├── flutter-layered-architecture-workspace/
│   └── SKILL.md             # dart workspace 構造の把握
├── flutter-layered-architecture-design-usecase/
│   ├── SKILL.md             # Usecase 設計・実装パターン
│   └── references/          # Request / package・injection / 依存・Fake
├── flutter-layered-architecture-design-repository/
│   ├── SKILL.md             # Repository 設計・実装パターン
│   └── references/          # package・injection / 状態・入出力 / テスト
├── flutter-layered-architecture-design-screen-mvvm/
│   ├── SKILL.md             # Screen 層 MVVM 設計判断
│   └── references/          # View / Action / State・Entity・Event / テスト
├── flutter-layered-architecture-annotations/
│   ├── SKILL.md
│   └── references/          # アノテーション別（拡張時もこの形式）
├── flutter-layered-architecture-resolve-package-layer/
│   └── SKILL.md             # package → レイヤー所属の解決
└── flutter-layered-architecture-linter-rule-{rule}/
    └── SKILL.md
```

### Workspace

ルート `pubspec.yaml` の `workspace:`・アプリ入口・子 package の `resolution: workspace` を読む。

* `flutter-layered-architecture-workspace`

### Design

Linter が保証しない設計と実装パターン。

* `flutter-layered-architecture-design-usecase` — Usecase の切り出し・Request／結線
* `flutter-layered-architecture-design-repository` — Repository の窓口・状態・DataInjection
* `flutter-layered-architecture-design-screen-mvvm` — Screen MVVM（lint が見ない設計判断）

### Annotations

付与判断・必須併記・連動 lint の入口。

* `flutter-layered-architecture-annotations`

### Architecture layer

package の所属レイヤーを `layered_architecture.yaml` から機械的に解決する。

* `flutter-layered-architecture-resolve-package-layer`

### Linter rules

ディレクトリ名・`SKILL.md` の `name` は診断コード（snake_case）の `_` を `-` に置換した形。

例: `usecase_single_method` → `flutter-layered-architecture-linter-rule-usecase-single-method`

| カテゴリ | rules |
| --- | --- |
| architecture | `architecture_layer_dependency`, `architecture_implementation_dependency` |
| file_layout | `one_public_type_per_file`, `public_type_file_name`, `unexported_public_must_be_internal` |
| usecase | `usecase_single_method`, `usecase_method_signature`, `usecase_immutable` |
| delegate | `delegate_execute_method`, `delegate_immutable`, `delegate_internal`, `delegate_no_nested_delegate`, `delegate_no_usecase_instantiation` |
| stateful | `stateful_immutable`, `stateful_has_mutable_state_stream`, `stateful_closes_mutable_state_stream`, `stateful_mutable_state_stream_state`, `stateful_methods_use_delegate` |
| viewmodel | `viewmodel_internal`, `viewmodel_has_entity_getter`, `viewmodel_entity_annotated`, `viewmodel_entity_differs_from_state`, `viewmodel_on_method_names` |
| state_entity | `state_entity_freezed`, `state_entity_internal`, `state_entity_exclusive`, `state_entity_required_parameters`, `state_entity_no_named_factory` |

## ドキュメントの追従

アノテーション・linter・`layered_architecture.yaml`・公開 API などを **実装または仕様変更したとき** は、対応する `docs/`（および必要ならルート `README`）を **同じ変更の一部として** 更新する。

* 新規ルール / アノテーション → `docs/linter-rules/` または `docs/annotations/` にリファレンスを追加し、ルート `README` の表へリンクする
* 新規ルール / アノテーション向け SKILL → `.apm/skills/` に追加し、本ファイルの SKILL 一覧も更新する
* `layered_architecture.yaml` のスキーマ・意味の変更 → `docs/layered_architecture_yaml.ja.md` / `.md` を更新する
* 振る舞い・診断メッセージ・設定キーの変更 → 既存ドキュメントの Details / Enable / 例も実装に合わせて直す
* 日本語（`.ja.md`）と英語（`.md`）の両方がある場合は両方を更新する（`README.ja.md` を正とし、`README.md` は英訳）

実装だけを先にマージし、ドキュメント更新を後回しにしない。

## バレルファイル

本リポジトリにおける **バレルファイル** は、各 package の `lib/` **直下**にある `.dart` ファイルのうち、`library;`（または名前付き `library ...;`）ディレクティブが記述されたものを指す。

* `lib/src/` 配下はバレルではない
* `library` ディレクティブが無い `lib/` 直下ファイルはバレルとして扱わない（無視してよい）
* package 役割（`@injection` / `@implementation` 等）の宣言は、バレルファイルの `library` に付与する

## アーキテクチャレイヤーの特定方法

package の所属レイヤーは、`layered_architecture.yaml` の定義と package 実パスから機械的に決める。手作業の命名推測（`usecase_*` など）では判定しない。

手順・判定結果の扱いの正本は  
`flutter-layered-architecture-resolve-package-layer` SKILL とする。

* YAML スキーマ: `docs/layered_architecture_yaml.ja.md`
* 依存方向（`level`）・診断: `flutter-layered-architecture-linter-rule-architecture-layer-dependency`
