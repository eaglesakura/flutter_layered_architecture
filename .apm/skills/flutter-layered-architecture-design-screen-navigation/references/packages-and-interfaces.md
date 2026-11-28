# パッケージと IF 役割

## 3 層の分離

```text
screen_navigation/          # IF + Request/Result/Input（ルーティング非依存）
screen_navigation_impl/     # go_router・Proxy・Launcher/Finisher 実装・DI
screen_feature_*/           # 画面本体 + Factory 実装のみ
```

* 画面 package は **他の screen package を import しない**
* 遷移したい側は `screen_navigation` の **`{画面名}Launcher` IF** だけを見る
* ルーティングパス・`GoRouter` 型は **impl の外に出さない**
* 実装のルーティングライブラリは **`go_router` を推奨**

## `{画面名}Factory`

* 役割: 画面 Widget を構築する（**実 Widget 型を navigation / 他画面から隠蔽**）
* 実装: **各 screen package**
* すべての画面に Factory を置く（タブ内コンテンツで Launcher が無くても Factory は必要）
* Factory 内で遷移しない（責務混在禁止）
* 画面引数が必要なら `build(context)` 内で `ref` 経由の Input を読むか、Proxy 配下の DI に任せる

```dart
abstract class TodoListScreenFactory {
  static final provider = Provider<TodoListScreenFactory>(
    (ref) => throw UnimplementedError('TodoListScreenFactory is not bound'),
  );

  Widget build(BuildContext context);
}
```

## `{画面名}Launcher`（慣習名）

* 役割: 遷移を実行する
* 実装: **`screen_navigation_impl`**（`go_router` 等）
* 典型メソッド（詳細は [request-result-and-flow.md](./request-result-and-flow.md)）:
  * `launch(...)` … **基本**。宣言的遷移。戻り値なし。入力はシリアライズ可能
  * `push(...)` … スタックに積む。結果あり / なし。非シリアライズ入力可

呼び出し側（画面・Usecase 周辺）は Launcher の Provider を watch/read し、`context.go` を直接書かない。

```dart
abstract class HomeScreenLauncher {
  static final provider = Provider<HomeScreenLauncher>(
    (ref) => throw UnimplementedError('$HomeScreenLauncher is not implemented'),
  );

  void launch(BuildContext context, {HomeScreenRequest? request});
}
```

## `{画面名}Finisher`

* 役割: 画面終了と **結果返却**
* 実装: **impl**（`push` で Result を待つ遷移と対になる画面のみ）
* `finish(context, {required Result result})` のように Result を載せて閉じる

## `{画面名}Proxy`

* 役割: ルート `builder` と Factory を接続し、**Input の DI override**を行う Widget（impl）
* ルート定義から Factory を直呼びしない（DI・パラメータ橋渡しを Proxy に集約）
* 詳細: [impl-and-proxy.md](./impl-and-proxy.md) / [input-via-di.md](./input-via-di.md)

## `AppRouterFactory`

* 役割: アプリ全体のルーティング（`MaterialApp.router` 相当）を構築
* 実装: impl に隠蔽。`main` / app 入口から結線する

## ダイアログ等

* `AlertDialogLauncher` / `ProgressDialogLauncher` / `SnackbarLauncher` のように、モーダル表示も同じ IF / impl 分離でよい
* Request / Result は navigation IF 側に置く
* callback 付きは `push` / `show` 系（シリアライズ不可入力）

## ナレッジベース

### DO: Factory は画面、Launcher / Finisher / Proxy は navigation

* 誰が実装するかを役割で固定する

### DO: 遷移 IF 名は `{画面名}Launcher`

* 呼び出し側の探索コストを下げる

### DO NOT: Factory と Launcher の責務を混在させる

* 画面構築と遷移ロジックが結合するとテストと差し替えが壊れる

### DO NOT: ルート定義から具象 Screen Widget を直接 new する

* Factory + Proxy + DI を経由し、差し替え可能にする
