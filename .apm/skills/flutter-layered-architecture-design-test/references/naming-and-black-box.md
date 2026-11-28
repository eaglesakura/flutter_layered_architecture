# 命名とブラックボックステスト

## 命名三区分（pubspec `name`）

| パターン | 判定 | 役割 |
| --- | --- | --- |
| `_test` サフィックス | `endsWith('_test')` | Unit Test **専用**。依存グラフの **leaf** |
| `_testing` サフィックス | `endsWith('_testing')` | **特定レイヤー／責務内**のテストサポート |
| `testing_` 接頭辞 | `startsWith('testing_')` | **横断・共有**のテストサポート（`testing_core` 等） |

`foo_testing` は `endsWith('_test')` に一致しない。詳細配置は [file-layout.md](./file-layout.md) を正とする。

## leaf 制約

* `_test` package は他 package から `dependencies` / `dev_dependencies` で依存されない
* Lint: `architecture_unit_test_package_dependency`（`*_test` のみ強制）

## ブラックボックス推奨

* `_test` からの検証は、対象 package の **export されたインターフェース**経由を推奨する
* `lib/src/` 内部への密結合を `_test` の主戦略にしない
* バレルは公開境界の手段の一例であり、正は export された IF

## 固有処理の所在

* DTO→Domain バインディング等の本番責務は **本番 package** に置く
* `_test` は検証・差し替え・テストダブルの置き場であり、本番責務の退避先ではない

## Lint との境界

| 関心 | Lint | 規約（本 SKILL） |
| --- | --- | --- |
| 本番等 → `*_test` の dependencies/dev_dependencies | WARNING | 禁止（leaf） |
| → `*_testing` / `testing_*` | 対象外 | 本番からは載せない（file-layout） |
| ブラックボックス／固有処理配置 | 対象外 | 本ドキュメント |
