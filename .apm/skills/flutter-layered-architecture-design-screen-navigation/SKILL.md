---
name: flutter-layered-architecture-design-screen-navigation
description: >-
  Flutter Layered Architecture の画面遷移・ナビゲーション設計正本 SKILL。
  IF（`{画面名}Launcher` / Factory / Finisher）と go_router 実装を分離し、
  Factory の DI で Widget を隠蔽、宣言的 `launch`（シリアライズ可能な入力・戻り値なし）を基本とし、
  `push`（戻り値・コールバック等の非シリアライズ入力）は必要なときだけ使う。
  画面間の引き継ぎは `*Input.provider` の DI override、ダイアログも同じ Launcher 規約。
  「画面遷移を足す」「Launcher」「launch と push」「タブ遷移」「go_router の置き場所」
  「画面 package の循環を避けたい」「遷移引数を DI で渡す」では必ず使う。
  Screen 内 MVVM は flutter-layered-architecture-design-screen-mvvm、
  Provider 結線は flutter-layered-architecture-design-dependency-injection、
  Dart 規約は coding-rules、package 所属は resolve-package-layer を使う。
---
# Flutter Layered Architecture / 画面遷移設計

Screen 層の画面間を **疎結合**にする。
ルーティング実装（推奨: `go_router`）は impl に閉じ込め、各画面は `{画面名}Launcher` 等の IF 経由で遷移する。

本 SKILL は遷移契約・package 分割・IF 役割・`launch` / `push` の使い分け・画面間データの DI 引き継ぎを扱う。
画面内部の MVVM は `design-screen-mvvm`、Provider の bind 形は `design-dependency-injection`、言語規約は `coding-rules` が正本。

正本の参考実装: `@app/app_packages/screen/navigation/` および各 `screen_feature_*`（やさしい漢字 / Grand Tube）。

## スコープ外（別正本）

| 関心 | 正本 |
| --- | --- |
| Screen MVVM（ViewModel / Entity / `onXXXX`） | `flutter-layered-architecture-design-screen-mvvm` |
| Provider の stub / inject / Container 構築 | `flutter-layered-architecture-design-dependency-injection` |
| Dart コーディング規約・一般 freezed DTO | `flutter-layered-architecture-coding-rules` |
| `@delegate`（Redirect 等の切り出し） | `flutter-layered-architecture-annotations` |
| package 所属レイヤー | `flutter-layered-architecture-resolve-package-layer` |
| workspace / 機能の所在の入口 | `flutter-layered-architecture-workspace` |

## いつ使うか

* 新規画面の遷移入口（`{画面名}Launcher`）・終了（Finisher）・Widget 生成（Factory）を設計するとき
* `launch`（宣言的）と `push` のどちらにするか決めるとき
* 遷移の Request / Result / Input をどこに置くか決めるとき
* 画面間の引数をコンストラクタではなく DI（`*Input.provider`）で渡すとき
* 画面 package 同士の循環参照を避けたいとき
* ルーティングライブラリ（`go_router`）の置き場所を揃えるとき
* Alert / Progress / Snackbar などモーダルも同じ IF / impl で切るとき

## 作業手順

1. **遷移種別を決める** — 基本は宣言的 `launch`。戻り値やコールバックが必要なら `push`
2. 遷移に必要な型を切り出す（Request / Result、必要なら Input）
3. IF を `screen_navigation` 側に置く（`{画面名}Launcher` / Factory / Finisher 等）
4. 各画面 package は **Factory 実装**を提供し、DI で結線する（他 screen を import しない）
5. `go_router` 等の具体実装は **`screen_navigation_impl` のみ**（Proxy / Launcher 実装）
6. 画面への引数は Proxy で `*Input.provider` を override して渡す（Widget コンストラクタにべったり載せない）
7. 細部は `references/` を読む

## 原則（要約）

* **画面 package 同士を直接参照しない**。遷移契約は `screen_navigation` に集約する
* **IF と実装を分離**する。実装のルーティングは **`go_router` を推奨**し、依存は **impl に閉じる**
* **Factory を DI**し、ルート定義・Launcher から実画面 Widget 型を隠蔽する
* **宣言的遷移（`launch`）を基本**とする
  * 戻り値なし
  * 入力はすべて **シリアライズ可能**（ルート・クエリ・enum・値オブジェクト等）
  * **Tab 切替も宣言的 `launch`** を推奨する
  * `push` でしか表現できない場合を除き、`launch` を選ぶ
* **`push` は例外的**に使う
  * コールバックなど **シリアライズ不可能な値**を渡してよい
  * **戻り値**（`Future<Result>`）を付けてよい
* **画面間の情報引き継ぎは DI 経由**（`{画面名}Input.provider` を Proxy で override）
* 慣習: 遷移 IF 名は **`{画面名}Launcher`**

典型 IF:

| IF | 役割 | 実装の置き場 |
| --- | --- | --- |
| `{画面名}Factory` | Widget 構築 | 各 screen package |
| `{画面名}Launcher` | 遷移の実行 | `screen_navigation_impl` |
| `{画面名}Finisher` | 終了と結果返却（必要な画面） | impl |
| `{画面名}Proxy` | ルートと Factory / Input DI の接続 | impl |
| `AppRouterFactory` | アプリ全体ルーティング | impl に隠蔽 |

## パッケージの役割

| パッケージ | 役割 |
| --- | --- |
| `screen_navigation`（機能ごとでも可） | 遷移 IF と Request/Result/Input。ルーティングライブラリ非依存 |
| `screen_navigation_impl` | go_router・Proxy・Launcher/Finisher 実装・DI |
| 各 `screen_*` | 画面本体 + Factory 実装。他画面や go_router に依存しない |

名前はリポジトリにより多少違うが、**IF 層 / 実装層 / 画面層**の分離を優先して読み替える。
所属レイヤーは `resolve-package-layer` で確認する。

## 追加ドキュメント

| 参照 | 使うとき |
| --- | --- |
| [packages-and-interfaces.md](./references/packages-and-interfaces.md) | Factory / Launcher / Finisher / Proxy / AppRouter / ダイアログ |
| [request-result-and-flow.md](./references/request-result-and-flow.md) | `launch` / `push`、シリアライズ可否、Request / Result |
| [input-via-di.md](./references/input-via-di.md) | `{画面名}Input` と ProviderScope override |
| [impl-and-proxy.md](./references/impl-and-proxy.md) | Proxy・ルート定義・シェル（タブ） |
| [go-router-extensions.md](./references/go-router-extensions.md) | go_router の安全ラッパ・ワークアラウンド例 |

## ナレッジベース

### DO: 遷移契約を navigation IF に寄せ、画面同士を切る

* Request/Result/Input を screen A が screen B の内部型にべったり依存させない

### DO: ルーティング実装は impl に閉じ、画面は Launcher だけ見る

* 画面や usecase から `GoRouter` / `context.go` を直接呼ばない

### DO: 宣言的 `launch` を第一選択にする

* タブ切替・ホーム復帰・スタックリセット相当は `launch` + シリアライズ可能な Request

### DO: 画面への引数は `*Input.provider` の DI で渡す

* Proxy が override し、画面は `ref.watch(XxxInput.provider)` する

### DO NOT: 画面 package 間で相互 import して遷移する

* 循環と結合度の温床になる

### DO NOT: シリアライズ可能な遷移なのに `push` + callback にする

* Deep link・状態復元・テスト差し替えが壊れる

### DO NOT: MVVM の State/Entity 設計を本 SKILL だけで済ませようとする

* 画面の中身は `design-screen-mvvm` へ
