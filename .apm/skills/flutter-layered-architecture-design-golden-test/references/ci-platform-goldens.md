# CI golden と platform golden

Alchemist は環境によって描画・比較パスを分ける。ハーネスで出力先を次に揃える。

| 種別 | 出力先（例） | 描画 | 比較環境 |
| --- | --- | --- | --- |
| **CI golden** | `goldens/CI/` | テキストを色ブロック化（`obscureText` 等） | Ubuntu CI 含む全環境 |
| **platform golden** | `goldens/macOS/` 等 | 文字込みの可読テキスト | 指定 HostPlatform のローカルのみ |

* **CI** — フォント・OS 差による偽陽性を減らす
* **platform** — 人間がレビューしやすい文字込み画像
* 生成 PNG は **両方コミット**する（片方だけだと CI かローカルのどちらかが壊れる）

`goldenTestMain` の `filePathResolver` で `goldens/$environmentName/$fileName.png` に固定すると、package 相対で安定する。

## 再現性

* `TickerMode(enabled: false)` / `MediaQuery.disableAnimations`
* 画像デコード待ち
* 必要なら `diffThreshold` を画面単位で緩める（外部 SDK のアンチエイリアス差など）。緩める理由をコメントする

## 更新コマンド

プロジェクトのテストランナーに従う。例:

```bash
# 実行（Golden を除外しない）
flutter test path/to/package

# Golden 更新（platform 画像を出す OS 上で実行する）
flutter test --update-goldens path/to/package
```

コマンド実行時は、プロジェクト規定のツールチェイン（あれば）に従う。
CI ワークフローでは Screen レイヤー（または Golden を含む package）が毎回比較される想定にする。
