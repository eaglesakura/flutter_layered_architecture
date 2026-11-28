# `@injection`（廃止）

`@injection` は廃止しました。DI 結線専用 package は pubspec `name` が **`_injection` で終わる**ことで識別します。

| 項目 | 内容 |
| --- | --- |
| 命名 | 例: `data_injection`, `usecase_injection` |
| バレル | `library;` + export（annotation なし） |
| 依存制約 | 同一レイヤーの `_injection` のみが `_impl` に依存可 — `flutter-layered-architecture-linter-rule-architecture-implementation-dependency` |
| 結線手順 | `flutter-layered-architecture-design-dependency-injection` |

旧ドキュメント: `docs/annotations/injection.ja.md`