# impl・Proxy・DI

## 置き場所

* `go_router` / `Navigator` / パス定義 → **`screen_navigation_impl` のみ**
* Launcher / Finisher / Proxy / `AppRouterFactory` の実装 → 同 impl
* 画面 Factory 実装 → 各 `screen_*`
* 結線（Provider override / inject）→ impl の injection（または app 入口から呼ぶ bindings）

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

Proxy 内で Factory を DI から取り、必要なら `state.extra` / path から Input を組み立てる。

## DI

* IF 側 Provider は未結線時 `UnimplementedError`
* impl / 各 screen の実装 Provider を injection で結びつける
* テストでは Fake Launcher / Fake Factory を差し替え可能にする

## シェル（タブ）ナビ

* `StatefulShellRoute` 等は impl のルータ定義に閉じる
* タブ識別子は navigation IF 側の enum / Input で共有し、パス文字列の重複定義を避ける

## go_router の注意

* `pushNamed` 後に `go` すると Future が解決されない等の既知不具合がある
* プロジェクト要件に応じた安全ラッパを impl に置く（[go-router-extensions.md](./go-router-extensions.md)）
* 画面側はそのラッパを知らず、Launcher 経由だけにする

## ナレッジベース

### DO: ルート定義の接続点を Proxy に集約する

* DI とパラメータ橋渡しが分散しない

### DO NOT: feature / usecase から `context.go` / `GoRouter` を直叩きする

* Launcher（と必要なら Finisher）経由に統一する
