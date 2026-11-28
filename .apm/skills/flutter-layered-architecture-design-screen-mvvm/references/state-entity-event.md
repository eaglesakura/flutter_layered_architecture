# State / Entity / Event の設計判断

Freezed・`@internal`・`@state`/`@entity` 排他・required 構築・entity getter は lint / annotations が保証する。
ここでは **何を載せるか** の判断を書く。

## ScreenState

* ViewModel あたり **単一**の `MutableStateStream<ScreenState>`
* 初期状態は provider 内で **主 factory に全引数を渡して**構築（named `.initial()` は lint で警告）
* **載せないもの**
  * Repository / Usecase の参照
  * Entity から冪等に再計算できる表示用フィールド
  * リストの「ヘッダ行」をデータ要素と混在させること
* **載せるもの**
  * 画面の可変真実（読み込み中、下書き、一覧データ等）
  * 画面 dispose で解放するリソース（キャンセル用コンテキスト等）— VM フィールドに置かない

`abstract` と `sealed` は状態の分岐の要否で選ぶ（常時 1 形なら abstract freezed でよい）。

## ScreenEntity

* View には **必ず Entity** を渡す。State を直接公開しない
* State→Entity は **専用 Delegate**（例: `…StateToEntityDelegate`）に切り出す
* ViewModel 本体や extension の private メソッドに変換ロジックを書かない
* ネストした表示モデル（リスト項目）への `@entity` は任意。ルート Entity は必須

```dart
StateStream<TodoListScreenEntity> get entity =>
    state.map(stateToEntityDelegate.execute);
```

## ScreenEvent（任意）

* ワンショット UI 副作用用（snackbar、一度きりのダイアログ等）
* **定常の表示切替には使わない**（それは Entity / State）
* パターン: `nothing` → バリアント → すぐ `nothing` に戻す一過性
* `emitEvent` は State 側の extension に置き、長く State に残さない
* ViewModel に `BuildContext` を渡さない

## ファイル配置（慣習）

```text
…/viewmodel/
├── *_viewmodel.dart
├── *_viewmodel.action.dart
├── state/
├── entity/
├── delegate/
└── （任意）event /
```
