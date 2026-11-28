# 画面間データの DI 引き継ぎ（`{画面名}Input`）

遷移パラメータのうち、**到達した画面 Widget が読む入力**はコンストラクタやグローバル変数にべったり載せない。
`{画面名}Input` を IF 側に置き、**Proxy が `ProviderScope` で override**して渡す。

これにより:

* 画面 package は Input の Provider だけを見る（ルーティング・`extra` を知らない）
* Factory の `build(context)` は薄く保てる
* テストで Input だけ差し替えられる

## `{画面名}Input`

* 置き場: `screen_navigation` または当該画面の公開 IF package（遷移契約と同じ層）
* `static final provider` を持ち、未注入時は `UnimplementedError`
* シリアライズ可能な値だけなら freezed 値オブジェクトでよい
* シェル（タブ）では `bodyBuilder` / `onTabSelected` など **非シリアライズの橋渡し**を Input に含めてよい（ルートからは Proxy が組み立てる）

```dart
@freezed
abstract class CropImageScreenInput with _$CropImageScreenInput {
  static final provider = Provider<CropImageScreenInput>(
    (ref) => throw UnimplementedError(
      'CropImageScreenInput is not provided. Wrap with ProviderScope.override.',
    ),
  );

  const factory CropImageScreenInput({
    required String imageFilePath,
    required int width,
    required int height,
    required int jpegQuality,
  }) = _CropImageScreenInput;
}
```

## Proxy での override

ルートの `builder` は Proxy を返す。Proxy が `extra` / path / 子 Widget から Input を組み立て、Factory の外で DI する。

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final extra = GoRouterState.of(context).extra;
  if (extra is! CropImageScreenInput) {
    return const SizedBox.shrink();
  }
  final factory = ref.watch(CropImageScreenFactory.provider);
  return ProviderScope(
    overrides: [
      CropImageScreenInput.provider.overrideWithValue(extra),
    ],
    child: Builder(
      builder: (context) => factory.build(context),
    ),
  );
}
```

シェル（タブ）例: 現在タブ・子コンテンツ・タブ選択コールバックを `HomeScreenInput` に載せ、`launch(selectedTab: ...)` でタブ切替する。

## Request と Input の違い

| 型 | 誰が使うか | 典型 |
| --- | --- | --- |
| Request | **Launcher 呼び出し側** → 遷移の指定 | `HomeScreenRequest.selectedTab` |
| Input | **到達画面**（と Factory）→ 表示に必要な入力 | `HomeScreenInput` / `CropImageScreenInput` |
| Result | **push の呼び出し側** ← Finisher | `EulaScreenNavigationResult` |

Launcher 実装が Request をルート引数や `extra` に変換し、Proxy がそれを Input に戻して DI する、という流れが多い。

## ナレッジベース

### DO: 画面は `ref.watch(XxxInput.provider)` で読む

* go_router の `extra` や path を画面から直接読まない

### DO: Input の組み立ては Proxy（impl）に閉じる

* Factory 実装や View にルート解析を散らさない

### DO NOT: Factory.build の引数にルート依存の巨大オブジェクトを直渡しし続ける

* DI に寄せないとテストと差し替えが壊れる
