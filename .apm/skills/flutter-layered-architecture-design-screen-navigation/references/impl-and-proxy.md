# impl・Proxy・シェル（タブ）

## 置き場所

* `go_router` / `Navigator` / パス定義 → **`screen_navigation_impl` のみ**（推奨実装は `go_router`）
* Launcher / Finisher / Proxy / `AppRouterFactory` の実装 → 同 impl
* 画面 Factory 実装 → 各 `screen_*`
* 結線（Provider inject）→ impl の injection（または app 入口から呼ぶ bindings）。形は `design-dependency-injection`

Redirect やルート組み立ての切り出しに Delegate を使う場合は `@delegate`（annotations）に従う。

## Proxy

ルートの `builder` は Proxy を返す。Factory をルート定義内で直呼びしない。

```dart
// DO
builder: (context, state) => const LoginScreenProxy(),

// DO NOT
builder: (context, state) =>
    ref.watch(LoginScreenFactory.provider).build(context),
```

Proxy 内で:

1. 必要なら `state.extra` / path / 子 Widget から `{画面名}Input` を組み立てる
2. `ProviderScope(overrides: [XxxInput.provider.overrideWithValue(...)])` で DI する
3. Factory を `ref.watch` して `build(context)` する

詳細は [input-via-di.md](./input-via-di.md)。

## シェル（タブ）ナビ

* `StatefulShellRoute` / `ShellRoute` 等は **impl のルータ定義に閉じる**
* タブ識別子は navigation IF 側の **enum** で共有し、パス文字列の重複定義を避ける
* **タブ切替は宣言的 `launch`**（例: `HomeScreenLauncher.launch(request: selectedTab(...))`）
* シェル本体への子コンテンツ・選択中タブ・選択コールバックは `HomeScreenInput` 等で DI する

ルーター側に「選択中タブ」の別状態を持たず、**ロケーション（ルート名）から導出**する実装が扱いやすい。

## DI

* IF 側 Provider は未結線時 `UnimplementedError`
* impl / 各 screen の実装 Provider を injection で結びつける
* テストでは Fake Launcher / Fake Factory / 固定 Input を差し替え可能にする

## go_router の注意

* `pushNamed` 後に `go` すると Future が解決されない等の既知不具合がある
* プロジェクト要件に応じた安全ラッパを impl に置く（[go-router-extensions.md](./go-router-extensions.md)）
* 画面側はそのラッパを知らず、Launcher 経由だけにする

## ナレッジベース

### DO: ルート定義の接続点を Proxy に集約する

* DI とパラメータ橋渡しが分散しない

### DO: タブも `launch` で宣言的に切り替える

* シェル内ローカル状態だけに閉じない（共有・復元が難しくなる）

### DO NOT: feature / usecase から `context.go` / `GoRouter` を直叩きする

* Launcher（と必要なら Finisher）経由に統一する
