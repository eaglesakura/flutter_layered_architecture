# 版の置き場所（ルート正本 / 子は any）

## なぜ分けるか

* dart workspace は **1 つの lock** で全体を解決する
* 子ごとに `^` を書くと、どこが実効版かわからず、更新漏れと制約衝突が起きる
* ルートに版を集約し、子は「使う／使わない」だけを `any` で示すと、揃えと更新が単純になる

## 外部 pub

### worktree（各 package）

```yaml
dependencies:
  flutter_riverpod: any
  freezed_annotation: any

dev_dependencies:
  freezed: any
  build_runner: any
```

* 必要な package にだけ列挙する（使わない package に書かない）
* `depend_on_referenced_packages` のため、import するなら pubspec に載せる

### ルート

実効版をルート `pubspec.yaml` に書く。よくある形:

```yaml
dependency_overrides:
  flutter_riverpod: ^3.5.0
  freezed_annotation: ^3.1.0
  freezed: 4.0.3
  build_runner: ^2.16.2
```

* 既存が overrides カタログなら、新規追加・更新もそこに揃える
* ルート自身が消費するツール類は、ルートの `dev_dependencies` に版または `any`＋overrides でもよい
* **子の `^` とルートの版を二重管理しない**

## workspace 内ローカル package

```yaml
dependencies:
  domain_todo: ^0.1.0
```

* `resolution: workspace` 前提
* 外部 pub の `any` 方針と混ぜない（ローカルは workspace 解決）
* path 依存が必要な例外（例: annotations の path）はリポジトリ慣習に従う

## 追加時のチェックリスト

1. ルートに実効版があるか（無ければ追加）
2. 利用する package の pubspec に `any` で載っているか
3. レイヤー境界・`_impl` 依存制限に抵触しないか（architecture linter）
4. `flutter pub get` が通るか

## 移行（子の `^` を `any` に寄せる）

1. 子にある外部 pub の `^x.y.z` を洗い出す
2. ルートに同じ名前の実効版が無ければ、現行解決版をルートへ写す
3. 子を `any` に置換する
4. `flutter pub get` と analyze で差分がないことを確認する
