---
name: flutter-layered-architecture-coding-rules
description: >-
  Flutter Layered Architecture 向け Dart / Flutter コーディング規約 SKILL。
  `*.dart` の実装・修正・リファクタ、ドキュメントコメント、enum、try-catch、
  `@internal` / `@visibleForTesting` 等の可視性、ファイルレイアウト、
  Delegate の切り出し判断、データオブジェクト（extension type / freezed / DTO）、
  `dart fix --apply` → analyze → format では必ずロードし、該当 `references/` だけ読む。
  「値オブジェクト作って」「コメント規約」「型付き catch」「ファイル分割」でも使う。
  `@delegate` / `@state` / `@entity` 等の付与と構造保証は
  flutter-layered-architecture-annotations、
  file_layout / delegate_* 診断は対応する linter-rule-*、
  画面 MVVM・Usecase / Repository 設計は design-* を使う。
  アプリ起動・DTD は flutter-app-debug、Maestro UI、Markdown 整形のみでは使わない。
---
# Flutter Layered Architecture / コーディング規約

`*.dart` を書く・直すときの **言語・ファイル・コメント・定番パターン** の土台である。
レイヤー設計・Annotation 付与・診断コードの深い修正は別 SKILL が正本。

Annotation / Linter が保証する構造は本 SKILL に再掲しない。該当箇所は案内表へ進む。

## スコープ外（別正本）

| 関心 | 正本 |
| --- | --- |
| `@usecase` / `@delegate` / `@state` / `@entity` / `@stateful` / `@viewModel` / `@injection` / `@implementation` の付与 | `flutter-layered-architecture-annotations` |
| Delegate の構造（`execute`・不変・`@internal`・入れ子禁止等） | annotations（`delegate.md`）+ `linter-rule-delegate-*` |
| 1 ファイル 1 public 型・ファイル名一致・未 export は `@internal` | `linter-rule-one-public-type-per-file` / `public-type-file-name` / `unexported-public-must-be-internal` |
| Screen State / Entity の Freezed 構築規約 | annotations（`state.md` / `entity.md`）+ `linter-rule-state-entity-*` |
| Screen MVVM / Usecase / Repository 設計 | `design-screen-mvvm` / `design-usecase` / `design-repository` |
| package 所属レイヤー | `resolve-package-layer` |
| workspace 構造 | `flutter-layered-architecture-workspace` |
| アプリ起動・DTD | `flutter-app-debug` |

## いつ使うか

* Dart の新規実装・修正・レビュー指摘の反映
* データオブジェクト / Delegate の切り出し判断 / enum / 例外 / 可視性 / ファイル配置 / コメント
* Analyzer 警告の直し方に迷ったとき

## 作業手順

1. 変更対象の種類を特定する（DTO、Delegate、enum、コメントのみ、など）
2. Annotation / lint 対象なら対応表へ進み、本 SKILL の重複説明は読まない
3. 下表から必要な `references/`（と snippets）だけロードする
4. 規約に沿って実装する
5. Analyzer / Formatter で検証する（迷ったら [fix-error](./references/fix-error.md)）

## Annotation / Lint で満たされるもの（案内）

| やりたいこと | 案内先 |
| --- | --- |
| `@delegate` を付ける・構造を満たす | `flutter-layered-architecture-annotations`（`references/delegate.md`） |
| `@state` / `@entity`（画面・Stateful のモデル） | 同 annotations（`state.md` / `entity.md`） |
| ViewModel / Stateful / Usecase の型 annotation | 同 annotations + 対応 `design-*` |
| 1 public 型 / ファイル名・未 export `@internal` | 対応する `flutter-layered-architecture-linter-rule-*` |
| 画面の `onXXXX`・使い捨て Delegate | `design-screen-mvvm`（`action-and-delegate.md`） |

## 文脈に応じたドキュメントのロード

| 参照 | 使うとき |
| --- | --- |
| [クラス作成テンプレート](./assets/architecture_data_object.code-snippets) | データオブジェクト等のひな形 |
| [data_object](./references/data_object.md) | DTO / 値オブジェクト / 一般 freezed（State/Entity 以外） |
| [delegate-pattern](./references/delegate-pattern.md) | Delegate の **切り出し判断・配置・命名・寿命**（構造は annotations） |
| [code_comment](./references/code_comment.md) | ドキュメントコメント・Example |
| [code_internal](./references/code_internal.md) | `@visibleForTesting` / `@protected` 等（未 export `@internal` は lint） |
| [dart_file_layout](./references/dart_file_layout.md) | library 名・配置の慣習（件数・ファイル名一致は lint） |
| [enum](./references/enum.md) | enum・dot-shorthands・switch 網羅 |
| [try-catch](./references/try-catch.md) | 例外処理・Error/Exception の catch |
| [exception-definition](./references/exception-definition.md) | 独自 Exception / Error の定義 |
| [fix-error](./references/fix-error.md) | `dart fix` / analyze / format |

必要な参照だけ読む。全部を一度にロードしない。

## 他 SKILL との境界

* 画面 MVVM: `flutter-layered-architecture-design-screen-mvvm`
* 画面遷移: `flutter-layered-architecture-design-screen-navigation`
* Usecase / Repository: `design-usecase` / `design-repository`
* Annotation 付与: `flutter-layered-architecture-annotations`
* アプリ起動・DTD: `flutter-app-debug`

## ナレッジベース

### DO: まず Annotation / lint の対象かを切り分ける

* 構造保証は診断側。本 SKILL は言語慣習と切り出し判断に留める

### DO: プロジェクト規定のコマンド prefix を付ける

* `mise` / `fvm` 等がある場合はそのルールに従う

### DO NOT: Annotation で検査される構造を本 SKILL に再掲して判断と混ぜる

* `@delegate` のメソッド数・不変性・State/Entity の Freezed 必須併記は各正本へ
