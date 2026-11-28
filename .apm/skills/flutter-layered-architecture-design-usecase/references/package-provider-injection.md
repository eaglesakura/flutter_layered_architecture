# Usecase の package・Provider・injection

Usecase の **切り出し・命名・Request** は親 SKILL（`flutter-layered-architecture-design-usecase`）が正本。

**Provider の書き方・`@implementation` / `{レイヤー}_injection`・app からの最終呼び出し・Container 構築** は次に集約している。重複して書かない。

* 正本: `flutter-layered-architecture-design-dependency-injection`
  * IF / 実装の `provider`（実装は実体型推奨）
  * `usecase_injection` 等での `inject`
  * app 集約とテスト差し替え

## Usecase 固有の置き場だけ（地図）

```text
…/usecase/todo/                 # usecase_todo（IF + stub provider）
└── _impl/                      # usecase_todo_impl（実体 provider、バレル @implementation）

…/usecase/injection/            # usecase_injection（@injection で bind）
```

* IF: `usecase_${機能}`、実装: 入れ子 `_impl`
* 本番コードは `_test` / `_testing` に依存しない（命名・leaf の正本: `flutter-layered-architecture-design-test`）
* 結線手順・コード形は DI 正本 SKILL を読む
