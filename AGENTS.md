# `@flutter_layered_architecture/`

*このファイルのディレクトリが、 `@flutter_layered_architecture` の参照で解決されるルートディレクトリである*

## 重要ファイル構成

```text
@flutter_layered_architecture/
├── README.md                 # プロジェクト概要（英語）
├── README.ja.md              # プロジェクト概要（日本語）
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

## バレルファイル

本リポジトリにおける **バレルファイル** は、各 package の `lib/` **直下**にある `.dart` ファイルのうち、`library;`（または名前付き `library ...;`）ディレクティブが記述されたものを指す。

* `lib/src/` 配下はバレルではない
* `library` ディレクティブが無い `lib/` 直下ファイルはバレルとして扱わない（無視してよい）
* package 役割（`@injection` / `@implementation` 等）の宣言は、バレルファイルの `library` に付与する

## アーキテクチャレイヤーの特定方法

package の所属レイヤーは、`layered_architecture.yaml` の定義と package 実パスから機械的に決める。手作業の命名推測（`usecase_*` など）では判定しない。

1. **定義ファイルを探す**  
   対象 package の package root から親ディレクトリへ辿り、最初に見つかった `layered_architecture.yaml` を適用する（正本の例: `@flutter_layered_architecture/layered_architecture.yaml`）。ルートまで無ければアーキテクチャ定義なし（lint は warning）。
2. **package 実パスを取る**  
   `.dart_tool/package_config.json` の package 名 → root URI で絶対パスを解決する。
3. **`path_prefix` 配下か判定する**  
   各レイヤーの `path_prefix` は定義ファイル所在ディレクトリからの相対パス。正規化（`/` 区切り・パス区切り境界）したうえで、package root がその配下（または同一）なら当該レイヤー所属とする。
4. **所属は高々 1 つ**  
   いずれの `path_prefix` にも属さない package はアーキテクチャ外（検査スキップ）。複数レイヤーにマッチすることは許可しない（`path_prefix` の重複・包括を避ける）。

詳細（依存方向の `level`、診断、例外）は  
`/flutter-layered-architecture-linter-rule-architecture-layer-dependency` SKILL を正とする。
