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
│   ├── domain/todo/          # domain_todo
│   ├── data/repository/todo/ # data_repository_todo (+ _impl)
│   ├── usecase/todo/         # usecase_todo (+ _impl)
│   └── screen/feature/todo_list/ # screen_feature_todo_list
└── skills/                   # 本リポジトリ連動の SKILL
```
