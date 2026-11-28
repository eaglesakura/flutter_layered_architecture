# `@implementation`（廃止）

`@implementation` は **廃止** しました。具象実装を公開する package の役割は、pubspec の `name` が **`_impl` で終わる**ことで表します（例: `data_repository_todo_impl`）。

* 依存制約: [`architecture_implementation_dependency`](../linter-rules/architecture_implementation_dependency.ja.md)
* 実装 Provider・結線: `flutter-layered-architecture-design-dependency-injection` SKILL

バレルには `library;` と export のみを置き、library annotation で役割を宣言しません。