# 状態網羅の指針

表示上意味のある状態を可能な限り網羅する。ロジック分岐の全組み合わせではなく、**見た目が変わる境界**を優先する。

## 観点

* sealed State の各バリアント（loading / loaded / error 等）
* ボタン有効・無効、入力あり / なし、変換済み / 未変換
* 選択肢・ソート・タブ等の UI バリエーション
* 表示 / 非表示フラグの境界
* 同意済み / 未同意、ログイン必須フラグなど、同一 State 内の見た目差分

## 洗い出し方

1. `ScreenState` の型（Freezed union）を列挙する
2. `StateToEntityDelegate` の分岐・フィールド写像を見る
3. ScreenImpl / 子の `switch` / 条件付き Widget を見る
4. 上記の積集合から「見た目が違う」ケースだけ `goldenTest` にする

`StateToEntityDelegate` には Unit Test も併設し、Golden は **代表状態の見た目**に寄せる（変換の網羅は Delegate テスト側）。

## ケース追加のタイミング

* 新しい State バリアントを足したとき
* Entity の表示フラグを足したとき
* デザイン変更で「同じ State でも見た目が分岐」したとき
