# 追加・更新・検証

## 追加

1. パッケージ名と、入れるレイヤー／package を決める
2. ルートに実効版を書く（既存カタログの書式に合わせる）
3. 利用する worktree package に `{name}: any` を足す
4. `flutter pub get`
5. import と analyzer を確認する

メジャー版や生成コードを伴うものは CHANGELOG／移行ガイドを先に読む。

## 更新（outdated）

```bash
flutter pub outdated
# 機械処理するなら
flutter pub outdated --json
```

* **Resolvable**（および Current / Upgradable / Latest）を見て上げられる版を判断する
* 互換性や制約で上がらないものはスキップし、理由を残す
* 更新するのは **ルートの版カタログだけ**（子の `any` は触らない）

```yaml
dependency_overrides:
  some_package: "^x.y.z"  # ルートのみ更新
```

## 再解決

```bash
flutter pub get
```

* アプリ package（多くは app レイヤー）がある場合は、そこでも `flutter pub get` する
* iOS CocoaPods 等はリポジトリ手順があれば従う（無い場合は `Podfile.lock` 削除を強要しない）

## 妥当性検証

* Analyzer が Success
* 関連テストが Success
* 必要なら対象プラットフォームのビルドが Success

## 問題が起きたときの対処順

1. 対象 package の README / CHANGELOG / 破壊的変更を確認する
2. コンパイルエラーを最小差分で直す
3. パッチ → マイナーの範囲で版を調整する
4. それでも無理なら **ルートの版を切り戻す**（無理な上げっぱなしにしない）

## 報告に含めるもの

* 追加／更新／スキップした依存と理由
* 検証したコマンドと結果
* 切り戻した場合はその旨
