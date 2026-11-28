# Repository の package・Provider・injection

Repository の **窓口・状態・入出力** は親 SKILL（`flutter-layered-architecture-design-repository`）が正本。

**Provider の書き方・`@implementation` / `{レイヤー}_injection`・app からの最終呼び出し・Container 構築** は次に集約している。重複して書かない。

* 正本: `flutter-layered-architecture-design-dependency-injection`
  * IF / 実装の `provider`（実装は実体型推奨）
  * `data_injection` 等での `inject`
  * app 集約とテスト差し替え

## Repository 固有の置き場だけ（地図）

```text
…/data/repository/todo/              # data_repository_todo（IF + stub provider）
└── _impl/                           # data_repository_todo_impl（実体 provider、バレル @implementation）

…/data/injection/                    # data_injection（@injection で bind）
```

* IF: `data_repository_${機能}`、実装: 入れ子 `_impl`
* 厚いテスト用実装が必要なときだけ `_testing`（Mock で足りるなら作らない）
* 本番は `_test` / `_testing` に依存しない
* 結線手順・コード形は DI 正本 SKILL を読む
