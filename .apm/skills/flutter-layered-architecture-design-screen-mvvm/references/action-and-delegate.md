# Action（onXXXX）と Delegate

メソッド名が `on...` であること・処理が `@delegate.execute` へ委譲されることは lint が検査する。
ここでは **切り方・ライフタイム・ロック** の設計判断を書く。

## 呼び出し口

* Widget からの操作はすべて `onXXXX()`（`onInitialize` 含む）
* ViewModel 本体ファイル + `part '...viewmodel.action.dart'` に拡張で置く
* `factory` / `ui` への part 分割はしない（action のみ）

## 使い捨て Delegate

* 各 `onXXXX` は都度 `OnXxxxxDelegate(...).execute(...)` する
* Delegate を ViewModel の **フィールドに保持しない**
* 依存はコンストラクタ注入。`execute` 内で Usecase を `new` しない（lint: `delegate_no_usecase_instantiation`）
* Delegate in Delegate やコールバックでの共通化はしない → 画面固有 `@internal` Usecase へ（`design-usecase`）

```dart
// *.action.dart（イメージ）
extension on TodoListScreenViewModel {
  Future<void> onAddTodo() {
    return OnAddTodoDelegate(
      state: state,
      addTodoUsecase: addTodoUsecase,
      stateToEntityDelegate: stateToEntityDelegate,
    ).execute();
  }
}
```

## updateWithLock

* 状態遷移だけを短いロックで行う
* **長時間の I/O・RPC はロック外**（先に通信してから短い更新、またはロック→通信→ロック）
* 失敗時の State / Event 方針を Delegate 内で完結させる

## 画面固有 Usecase

* Delegate 間で繰り返すビジネス手順は package internal Usecase に切る
* レイヤー公開 Usecase は ViewModel の provider で DI する
* 画面固有 Usecase を provider のフィールドとして常時保持しない（必要な action 内で生成してよい）

## 初期化

* `onInitialize` をコンストラクタ / Provider から呼ばない
* ルート Screen の mount（`useEffect` 等）から呼ぶ
