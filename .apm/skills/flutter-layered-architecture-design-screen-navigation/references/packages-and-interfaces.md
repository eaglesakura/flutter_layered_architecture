# パッケージと IF 役割

## 3 層の分離

```text
screen_navigation/          # IF + Request/Result（ルーティング非依存）
screen_navigation_impl/     # go_router・Proxy・Launcher/Finisher 実装・DI
screen_feature_*/           # 画面本体 + Factory 実装のみ
```

* 画面 package は **他の screen package を import しない**
* 遷移したい側は `screen_navigation` の Launcher IF だけを見る
* ルーティングパス・`GoRouter` 型は **impl の外に出さない**

## `{画面名}Factory`

* 役割: 画面 Widget を構築する
* 実装: **各 screen package**
* すべての画面に Factory を置く（タブ内コンテンツで Launcher が無くても Factory は必要）
* Factory 内で遷移しない（責務混在禁止）

```dart
abstract class TodoListScreenFactory {
  static final provider = Provider<TodoListScreenFactory>(
    (ref) => throw UnimplementedError('TodoListScreenFactory is not bound'),
  );

  Widget build(BuildContext context /*, 必要なら Input */);
}
```

## `{画面名}Launcher`

* 役割: 遷移を実行する
* 実装: **`screen_navigation_impl`**
* 典型メソッド:
  * `launch(...)` … スタックをリセットする宣言的遷移（`go` 相当）
  * `push(...)` … スタックに積む（結果あり / なし）

呼び出し側（画面・Usecase 周辺）は Launcher の Provider を watch/read し、`context.go` を直接書かない。

## `{画面名}Finisher`

* 役割: 画面終了と **結果返却**
* 実装: **impl**（必要な画面のみ）
* `push` で Result を待つ遷移と対になる

## `{画面名}Proxy`

* 役割: ルート `builder` と Factory を接続する Widget（impl）
* ルート定義から Factory を直呼びしない（DI・パラメータ橋渡しを Proxy に集約）

## `AppRouterFactory`

* 役割: アプリ全体のルーティング（`MaterialApp.router` 相当）を構築
* 実装: impl に隠蔽。`main` / app 入口から結線する

## ダイアログ等

* `AlertDialogLauncher` のように、モーダル表示も同じ IF / impl 分離でよい
* Request / Result は `screen_navigation` に置く

## ナレッジベース

### DO: Factory は画面、Launcher / Finisher / Proxy は navigation

* 誰が実装するかを役割で固定する

### DO NOT: Factory と Launcher の責務を混在させる

* 画面構築と遷移ロジックが結合するとテストと差し替えが壊れる
