# `@injection`（廃止）

`@injection` は **廃止** しました。DI 結線用 package の役割は、pubspec の `name` が **`_injection` で終わる**ことで表します（例: `data_injection`）。

* 依存制約: [`architecture_implementation_dependency`](../linter-rules/architecture_implementation_dependency.ja.md)
* 結線・Provider パターン: `flutter-layered-architecture-design-dependency-injection` SKILL

バレルには `library;` と export のみを置き、library annotation で役割を宣言しません。