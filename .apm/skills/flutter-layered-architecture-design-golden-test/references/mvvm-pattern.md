# MVVM × Golden の基本パターン

## 前提となる View 分割

本番の Screen 層は **完全分離**する（正本: `design-screen-mvvm` の view-and-widget）。

| 型 | 役割 | Golden |
| --- | --- | --- |
| `{画面名}Screen` | DI・ViewModel の `watch`、`onInitialize`、Event 購読 | **撮らない** |
| `{画面名}ScreenImpl` | Entity に基づく見た目。子 Widget もここ | **撮影対象** |

* 子は Entity **全体**を一括 watch せず、`select` / `watchBy` で必要分だけ watch する
* Entity に loading / loaded / error 等のバリアントがあれば、型（または位相）を判定して子 Widget へ `switch` する
* ScreenEntity をコンストラクタフィールドにした見た目 Widget は作らない（Widget 内で watch）
* ViewModel / Launcher は `onTap()` 等のコールバック内で `ref.read` する

これにより `ProviderScope` + `overrideWithBuild` で Entity を固定注入し、**ViewModel なし**で見た目だけを検証できる。

## 推奨: State + StateToEntityDelegate

```text
ScreenState（テスト用ファクトリ）
  → StateToEntityDelegate.execute()
  → ScreenEntity
  → {画面名}ScreenProviders.entity.overrideWithBuild
  → ScreenImpl
```

* Delegate は **本番と同じ実装**を使う（テスト専用の変換を置かない）
* State ファクトリは helpers に置き、ローカライズ文字列が要る場合はハーネスの inject 後に組み立てる
* `StateToEntityDelegate` 自体には Unit Test も併設し、Golden では **代表状態の見た目**に寄せる

## 補助: Entity 直接注入

Entity 組み立てが自明で変換分岐が無い画面では、Entity を直接 `overrideWithBuild` してよい。
新規は **State + Delegate 経由を優先**する。

## ViewModel Mock は実装しない

Golden の目的は見た目と（MVVM では）State→Entity マッピングである。

* ViewModel を Mock / Fake して「描画だけ」にする必要はない
* Screen と ScreenImpl の分離と Entity Provider の override で、ViewModel から切り離す
* ViewModel の挙動・非同期・故障注入は Unit Test（`design-test` / `design-screen-mvvm` testing）へ

## 見た目を固定注入できる形にする（旧 design-screen-mvvm testing）

* 見た目は **Entity を固定注入できる形**にする
* 操作経路の検証で ViewModel を `build` 中に `watch` しすぎない（本番と同じ watch/read 規律）

Golden 容易性は本番の MVVM 規律そのものから来る。Golden のために別の watch 経路を作らない。

## Entity Provider の形

典型は ViewModel の `entity` を `StateStreamProvider` 等で公開し、ScreenImpl がそれを `watch` する。

```dart
// 概念例（プロジェクトの Provider 規約に合わせる）
static final entity = StateStreamProvider.autoDispose.stateBy(
  XxxScreenViewModel.provider,
  (viewModel) => viewModel.entity,
);
```

Golden ではこの `entity` を `overrideWithBuild` で固定値に差し替える。
派生 Provider（loading / loaded 等）が `entity` に依存していれば、override 一つで連動する。
