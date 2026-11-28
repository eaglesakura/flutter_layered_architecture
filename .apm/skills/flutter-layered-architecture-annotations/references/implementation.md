# `@implementation`（廃止）

`@implementation` は廃止しました。具象実装を公開する package は pubspec `name` が **`_impl` で終わる**ことで識別します。

| 項目 | 内容 |
| --- | --- |
| 命名 | 例: `data_repository_todo_impl`, `usecase_todo_impl` |
| バレル | `library;` + export（annotation なし） |
| 依存制約 | この package への直接依存は、同一レイヤー名の `_injection` のみ — `flutter-layered-architecture-linter-rule-architecture-implementation-dependency` |
| Provider・結線 | `flutter-layered-architecture-design-dependency-injection` |

旧ドキュメント: `docs/annotations/implementation.ja.md`