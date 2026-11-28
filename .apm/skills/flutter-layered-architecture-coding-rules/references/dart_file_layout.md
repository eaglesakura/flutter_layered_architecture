# Dart ファイル・レイアウト（慣習）

次は **Linter が保証**する。診断の修正・詳細は各 SKILL を正とする。

| 規約 | 正本 |
| --- | --- |
| 1 ファイルに public 名前付き型は高々 1 | `flutter-layered-architecture-linter-rule-one-public-type-per-file` |
| 唯一の public 型名 = ファイル名（snake_case） | `flutter-layered-architecture-linter-rule-public-type-file-name` |
| バレル未 export の公開トップレベルは `@internal` か private | `flutter-layered-architecture-linter-rule-unexported-public-must-be-internal` |

本ドキュメントは lint が見ない **library 名・配置の慣習** を扱う。

## ソースファイル名

* Dart ソースは `snake_case.dart`
* public 型を置くファイルは型名の snake_case と一致させる（上記 lint と整合）

## library（バレル）ファイル

* 各 package の公開面は `lib/{パッケージ名}.dart`
* `library;`（または名前付き `library`）を置き、公開 API だけ `export`
* `lib/src/` は実装。バレルではない（`AGENTS.md` のバレル定義と一致）
* DI / 実装 package の役割は pubspec `name` の `_injection` / `_impl` サフィックスで表す（バレル annotation は使わない）

```dart
// lib/usecase_todo.dart
library;

export 'src/add_todo_usecase.dart';
```

## 配置

* 実装は `lib/src/` 配下に機能単位で置く
* Delegate は親の近くの `delegate/`（[delegate-pattern.md](./delegate-pattern.md)）
* package 所属レイヤーは名前推測ではなく `resolve-package-layer`

## ナレッジベース

### DO: library ファイル名をパッケージ名と同一にする

* `import 'package:foo/foo.dart'` を統一する

### DO: 公開 API だけをバレルから export する

* 実装詳細は `lib/src/` + `@internal`（lint）

### DO NOT: 1 ファイル複数 public 型やファイル名不一致を「慣習」だけで許す

* 機械検査は file_layout linter が正本
