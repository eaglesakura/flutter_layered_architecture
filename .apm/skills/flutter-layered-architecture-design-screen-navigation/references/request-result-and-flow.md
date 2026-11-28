# Request / Result と `launch` / `push`

遷移の入出力型は **`screen_navigation`（IF 側）** に置く。画面 package の内部 State / Entity を遷移契約に載せない。

一般の freezed / DTO 規約は `coding-rules`（`data_object.md`）。Screen State/Entity は `design-screen-mvvm`。
画面 Widget への引数渡し（`*Input`）は [input-via-di.md](./input-via-di.md)。

## フローの選び方（最重要）

| メソッド | 使うとき | 入力 | 戻り値 |
| --- | --- | --- | --- |
| `launch` | **基本選択**。ホーム・タブ切替・スタックリセット相当の宣言的遷移 | **すべてシリアライズ可能** | **なし**（`void` / `Future<void>` で完了待ちのみ可） |
| `push` | `launch` で表現できないときだけ。結果待ち・コールバック受け渡し | シリアライズ不可（callback 等）を含めてよい | `Future<Result>` または `Future<void>` |

**判断の目安:**

1. 戻り値が要るか？ → 要るなら `push` + Finisher
2. コールバックや閉鎖環境のオブジェクトが要るか？ → 要るなら `push`（例: ProgressDialog の callback）
3. それ以外（表示タブ・初期 ID・フラグ等）→ **`launch`**
4. **Tab 切替は宣言的 `launch` を推奨**（シェル内でもルート名で表現する）

`push` でしかできない典型例: ログイン結果待ち、EULA 同意結果、画像選択結果、プログレス付き非同期処理ダイアログ。

## Request（主に `launch`）

* Launcher に渡す遷移パラメータ（タブ指定・初期 ID など）
* **シリアライズ可能**であること（enum・文字列・数値・freezed 値オブジェクトなど）
* sealed / freezed でバリエーションを表してよい

```dart
@freezed
sealed class HomeScreenRequest with _$HomeScreenRequest {
  const factory HomeScreenRequest.defaultTab() = HomeScreenRequestDefaultTab;
  const factory HomeScreenRequest.selectedTab({
    required HomeScreenTab tab,
  }) = HomeScreenRequestSelectedTab;
}

abstract class HomeScreenLauncher {
  void launch(BuildContext context, {HomeScreenRequest? request});
}
```

## Result / NavigationResult（`push`）

* 呼び出し側が待つ結果。成功・キャンセル・失敗などを型で表す
* Finisher が結果を載せて pop する

```dart
abstract class EulaScreenLauncher {
  Future<EulaScreenNavigationResult> push(BuildContext context);
}
```

戻りが不要でもスタックに積むだけの遷移は `Future<void> push(...)` でよい（設定画面など）。
それでも **宣言的に置き換え可能なら `launch` を優先**する。

## シリアライズ可否

| 種別 | 例 | 置き場 |
| --- | --- | --- |
| 可（`launch` 向け） | tab enum、ID 文字列、クエリ相当の値 | Request |
| 不可（`push` 向け） | `Future` を返す callback、`void Function(...)` | Request のフィールド（ダイアログ等） |

宣言的ルートに載せられないオブジェクトを `launch` に押し込まない。
逆に、ID や enum だけで足りるのに `push` + callback にしない。

## ダイアログ

Alert / Progress / Snackbar も **同じ Launcher 規約**で切る。
進捗コールバック付き Progress は `push` / `show` 系（シリアライズ不可入力の典型）。

## ナレッジベース

### DO: 迷ったら `launch` + シリアライズ可能な Request

* Deep link・状態復元・テスト Fake が単純になる

### DO: `push` の結果型は navigation IF に閉じる

* 呼び出し画面が遷移先 package の内部型に依存しない

### DO NOT: ルーティングパス文字列を feature に散らす

* 名前付きルートは Proxy / Tab enum 等と一貫させ、ハードコードしない

### DO NOT: `launch` の Request に callback を載せる

* 宣言的遷移の前提（復元・共有）が崩れる
