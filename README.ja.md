# Flutter Layered Architecture

Flutter Layered Architecture のプロジェクト導入をサポートするリポジトリである。

Custom Linter・Runtime・SKILL の組み合わせで、レイヤード構成の導入と運用を支援する。

## 構成要素

| 要素 | 役割 |
| --- | --- |
| Custom Linter | レイヤー境界や依存方向などの規約を静的に検査する |
| Runtime | 実行時にレイヤード構成を支えるライブラリを提供する |
| SKILL | Agent 向けの導入・運用手順を提供する |

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
│   ├── domain/todo/          # domain_todo
│   ├── data/repository/todo/ # data_repository_todo (+ _impl)
│   ├── usecase/todo/         # usecase_todo (+ _impl)
│   └── screen/feature/todo_list/ # screen_feature_todo_list
└── skills/                   # 本リポジトリ連動の SKILL
```
