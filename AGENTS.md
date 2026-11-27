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
└── skills/                   # 本リポジトリ連動の SKILL
```

## ドキュメントの追従

アノテーション・linter・`layered_architecture.yaml`・公開 API などを **実装または仕様変更したとき** は、対応する `docs/`（および必要ならルート `README`）を **同じ変更の一部として** 更新する。

* 新規ルール / アノテーション → `docs/linter-rules/` または `docs/annotations/` にリファレンスを追加し、ルート `README` の表へリンクする
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
