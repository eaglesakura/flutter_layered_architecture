# View / Widget（Screen・ScreenImpl）

## 分割（完全分離）

`{画面名}Screen`（DI・ライフサイクル）と `{画面名}ScreenImpl`（見た目）を **完全に分離**する。
Impl が ViewModel の `watch` や `onInitialize` を担わない。Screen が描画ロジックを持たない。

| 型 | 役割 | やってよいこと | やらないこと |
| --- | --- | --- | --- |
| `{画面名}Screen` | public の入口・DI | ViewModel の `watch`、`onInitialize`、Event 購読、入力の `ProviderScope` override | レイアウト・Entity の描画分岐 |
| `{画面名}ScreenImpl` | 見た目のルート | Entity（の一部）を `watch` / `select` / `watchBy`、子 Widget への分岐 | ViewModel の `watch`、初期化、DI override の親役 |

* Screen に `@internal` を付けない（公開入口）。Impl は `@internal` でよい
* Golden は ScreenImpl を撮る（正本: `design-golden-test`）

```dart
final class TodoListScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(TodoListScreenViewModel.provider);
    useEffect(() {
      viewModel.onInitialize();
      return null;
    }, [viewModel]);
    return const TodoListScreenImpl();
  }
}
```

入力 ID などを子ツリーへ渡すときは、Screen 側で `ProviderScope` + `overrideWithValue` し、Impl 以下は Provider から読む（コンストラクタでバケツリレーしない）。

参考（Sheet 入口で DI、本体は Impl）: `@app` の `screen/feature_grand_tube/playback_comment`（`PlaybackCommentSheet` / `PlaybackCommentSheetImpl`）。

## Entity バリアントでの子切替

Entity に **ロード中 / ロード済み / エラー** 等のバリアント（sealed / Freezed union、または同等の位相）がある場合:

1. ScreenImpl（または一覧領域のルート）で **型（または位相）を判定**する
2. 対応する **子 Widget に `switch`** する（大きな UI を1 Widget に詰め込まない）
3. 各子は自分に必要な Entity 断片だけを `watch` する

```dart
// ScreenImpl: バリアントだけ select し、子へ振り分ける
final phase = ref.watch(
  XxxScreenProviders.entity.select(
    (e) => switch (e) {
      XxxScreenEntityLoading() => _Phase.loading,
      XxxScreenEntityLoaded() => _Phase.loaded,
      XxxScreenEntityError() => _Phase.error,
    },
  ),
);

return switch (phase) {
  .loading => const XxxLoadingBody(),
  .loaded => const XxxLoadedBody(),
  .error => const XxxErrorBody(),
};
```

位相が enum フィールドの場合も同様に、位相だけを `select` して子へ振り分ける（参考: `playback_comment` の list 領域の `switch`）。

## watch / read（必要な要素だけ）

* **表示に使う値**は `build` 内で `ref.watch`（必要なら `select` / `watchBy`）
* **操作・コールバック内**は `ref.read` で ViewModel / Usecase を取る
* 子 Widget の `build` で ViewModel 全体を `watch` しない
* 子から `viewModel.onXXXX()` を `build` 中に呼ばない（ハンドラ内で `read`）

### Entity 全体の一括 watch を避ける

Entity を丸ごと `ref.watch(Providers.entity)` すると、無関係なフィールド更新でも再 build される。
**必要な要素だけ**を取る。

| 手段 | 使うとき |
| --- | --- |
| `ref.watch(provider.select((e) => …))` | フィールドやバリアント判定など、浅い抽出 |
| `ref.watchBy(provider, (e) => …)`（`flutter_riverpod_watch_plus`） | 深い比較が要る抽出 |

```dart
// DO: メッセージだけ
ref.watch(XxxScreenProviders.error.select((e) => e.message));

// DO NOT: 画面全体が Entity 全更新で再描画される
final entity = ref.watch(XxxScreenProviders.entity);
```

派生 Provider（`loaded` / `error` 等）を `Providers` に置く場合も、中身は `entity.select` で絞る。

## Entity をフィールドにした Widget を定義しない

子 Widget に `final XxxEntity entity` や、Entity からバラした表示用フィールドをコンストラクタで渡して描画しない。
**Widget 内で `ref.watch` / `select` / `watchBy` する**（コールバックだけ親から渡すのは可）。

```dart
// DO NOT
class XxxLoadedBody extends StatelessWidget {
  const XxxLoadedBody({required this.entity});
  final XxxScreenEntityLoaded entity;
  // ...
}

// DO
class XxxLoadedBody extends ConsumerWidget {
  const XxxLoadedBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(
      XxxScreenProviders.loaded.select((e) => e.text),
    );
    return Text(text);
  }
}
```

なぜか: 親が Entity を保持・転送すると、(1) 一括 watch が親に残りやすい、(2) Golden / 単体で子だけ差し替えにくい、(3) Screen/Impl 分離の利点が薄れる。

リスト行など **ドメイン行 Entity**（画面ルート Entity ではない）を `itemBuilder` で渡すのは、行が Provider に載っていない場合の例外としてよい。画面ルートの ScreenEntity には適用しない。

## Riverpod

* Provider はクラスの `static final`。グローバルトップレベル Provider を置かない（lint: `provider_static_final`）
* **`@riverpod` コード生成は使わない**（手書き `Provider.autoDispose`）
* ViewModel / entity 等の **Provider 定義**では、create 直下の依存は `ref.watch`、かつ `dependencies` に列挙する（lint: `provider_ref_watch` / `provider_dependencies`）。`stateBy` のみの派生 Provider は `dependencies` 強制の対象外
* Widget の `build` / ハンドラ内の `ref.watch` / `ref.read` は本 lint の対象外（上記「watch / read」節）

## Widget 種別

* `HookConsumerWidget` / `ConsumerWidget` / `HookWidget` 等の Stateless 系
* **`StatefulWidget` は作らない**。ローカル UI 一時状態は Hooks、画面状態は ViewModel

## DO NOT

* Screen と ScreenImpl の責務を混ぜる（Impl で DI・初期化、Screen で大きなレイアウト分岐）
* Entity 全体を一括 `watch` してからフィールドを配る
* ScreenEntity（やその大部分）をコンストラクタ引数にした見た目 Widget を定義する
* 画面 package から `go_router` / `Navigator` を直叩きする → `design-screen-navigation`
* ビジネスロジックを Widget に書く
* 表示状態を `build` 内で `ref.read` する（再描画されない）
