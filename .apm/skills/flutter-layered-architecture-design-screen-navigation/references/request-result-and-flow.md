# Request / Result と遷移フロー

遷移の入出力型は **`screen_navigation`** に置く。画面 package の内部 State / Entity を遷移契約に載せない。

一般の freezed / DTO 規約は `coding-rules`（`data_object.md`）。Screen State/Entity は `design-screen-mvvm`。

## Request

* Launcher に渡す遷移パラメータ（タブ指定・初期 ID など）
* sealed / freezed でバリエーションを表してよい

```dart
@freezed
sealed class HomeScreenRequest with _$HomeScreenRequest {
  const factory HomeScreenRequest.defaultTab() = HomeScreenRequestDefaultTab;
  const factory HomeScreenRequest.selectedTab({
    required HomeScreenTab tab,
  }) = HomeScreenRequestSelectedTab;
}
```

## Result / NavigationResult

* `push` の戻りとして、呼び出し側が待つ結果
* 成功・キャンセル・失敗などを型で表す
* Finisher が結果を載せて pop する

```dart
abstract class LoginScreenLauncher {
  Future<LoginScreenNavigationResult> push(BuildContext context);
}
```

## Input（埋め込み・シェル）

* タブシェルや親が子コンテンツを載せるときの橋渡し型
* Proxy / シェル側で Factory に渡す。ルート文字列のハードコードを避ける

## フローの選び方

| メソッド | 使うとき |
| --- | --- |
| `launch` | ホーム等へスタックをリセットして戻る／乗り換える |
| `push`（Result あり） | ログイン・確認など、結果が必要 |
| `push`（Result なし） | 設定など、閉じるだけでよい |

## ナレッジベース

### DO: 遷移契約を navigation IF の型に閉じる

* 呼び出し画面が遷移先 package の内部型に依存しない

### DO NOT: ルーティングパス文字列を feature に散らす

* 名前付きルートは Proxy / Tab enum 等と一貫させ、ハードコードしない
