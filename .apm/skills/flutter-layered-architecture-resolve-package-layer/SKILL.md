---
name: flutter-layered-architecture-resolve-package-layer
description: >-
  Flutter Layered Architecture で package の所属レイヤーを機械的に特定する。
  layered_architecture.yaml の探索、package_config.json による実パス解決、
  path_prefix 配下判定、単一所属（高々 1 つ）の制約を扱う。
  「どのレイヤーか」「レイヤー所属を調べる」「この package は domain / usecase / data のどれか」
  「アーキテクチャ外か」「path_prefix で判定」「新規 package の配置先レイヤー」
  「usecase_* のような名前推測でレイヤーを決めない」「layer membership」のときは必ず使う。
  architecture_layer_dependency / architecture_implementation_dependency の前段で
  所属を確定するときも必ずロードする。
  依存方向（level）の検査・ignore・診断修正だけなら
  flutter-layered-architecture-linter-rule-architecture-layer-dependency を使う。
  YAML スキーマ（layers / rules / keywords）全体の編集は
  docs/layered_architecture_yaml を正とする。
---
# Package 所属レイヤーの解決

所属レイヤーは、命名慣習ではなく **定義ファイルと実パス** で決まる。
名前だけ見て `usecase_*` → usecase と推測すると、配置ミスやアーキテクチャ外 package を取り違える。

## スコープ外（別正本）

| 関心 | 正本 |
| --- | --- |
| 依存方向（`level`）・ignore・診断 | `flutter-layered-architecture-linter-rule-architecture-layer-dependency` |
| `_impl` package への依存制限 | `flutter-layered-architecture-linter-rule-architecture-implementation-dependency` |
| YAML スキーマ・`rules` / `keywords` | `@flutter_layered_architecture/docs/layered_architecture_yaml.ja.md` |

## 作業手順

対象は **package root**（`pubspec.yaml` があるディレクトリ）とする。

1. **定義ファイルを探す**  
   package root から親へ辿り、最初に見つかった `layered_architecture.yaml` を使う。  
   正本の例: `@flutter_layered_architecture/layered_architecture.yaml`。  
   ルートまで無ければ「定義なし」（lint は warning）。以降の所属判定はできない。
2. **package 実パスを取る**  
   `.dart_tool/package_config.json` で package 名 → root URI を解決する。  
   作業ツリー上の相対パスだけに頼らない。依存先や別 package は、常に package_config 経由の絶対パスで揃える。
3. **`path_prefix` と突き合わせる**  
   各レイヤーの `path_prefix` は、定義ファイル所在ディレクトリからの相対パス。  
   separator を正規化し、**パス区切り境界**を尊重したうえで、package root が配下（または同一）ならマッチとする。  
   部分文字列の偶然一致（例: `…/data` と `…/database`）で所属させない。
4. **所属を 0 または 1 に正規化する**  
   * 0 件 → アーキテクチャ外（レイヤー検査の対象外になりうる）  
   * 1 件 → そのレイヤー所属（`level` があれば依存方向比較の入力）  
   * 2 件以上 → 許可しない。`path_prefix` の重複・包括を直し、所属不定のまま依存方向を論じない

## 出力形式

所属を答えるときは、次の形で報告する（推測根拠を混ぜない）。

```text
package: <pubspec name>
definition: <layered_architecture.yaml の絶対パス | missing>
package_root: <package_config で解決した絶対パス>
matches: <layer name>（level: <n|none>） | none | ambiguous(<names>)
verdict: in-layer | out-of-architecture | ambiguous | no-definition
```

## 判定結果

| verdict | 意味 |
| --- | --- |
| `in-layer` | 単一レイヤーにマッチ。依存方向の議論に進める |
| `out-of-architecture` | どの `path_prefix` にも属さない |
| `ambiguous` | 複数マッチ。定義を直すまで依存方向検査は行わない |
| `no-definition` | 定義不在またはパース失敗 |

`level` の大小による **依存の可否** は本 SKILL の範囲外である。

## 例

### 例: 単一レイヤー（in-layer）

`domain_todo`（`example/domain/todo`）は `path_prefix: example/domain` にマッチし、`domain`（level 2）所属になる。

### 例: アーキテクチャ外（out-of-architecture）

`flutter_layered_architecture_lint`（`packages/lint`）はいずれの `path_prefix` にも属さない。レイヤー依存検査の対象外である。

### 例: 名前推測は使わない

`usecase_todo` という名前だけでは usecase レイヤーと断定しない。  
`package_config` の root が `example/usecase/...` 配下かを確認してから判定する。

## ナレッジベース

### DO: 定義と実パスだけで決める

* YAML 探索 → package_config → `path_prefix` の順で揃えると、Agent 間で判定が一致する

### DO NOT: package 名やフォルダ名の慣習だけで決める

* 理由: 配置と名前がずれたとき、誤ったレイヤー境界で依存を許可／拒否してしまう

```text
# DO NOT
usecase_todo という名前 → usecase レイヤー

# DO
package_config の root が path_prefix example/usecase 配下 → usecase
```

### DO: path_prefix を兄弟ディレクトリで切る

* 親と子を別レイヤーにすると包括で `ambiguous` になり、検査が止まる

## 関連

* workspace の package 一覧: `flutter-layered-architecture-workspace`
* 定義ファイル: `@flutter_layered_architecture/layered_architecture.yaml`
* YAML スキーマ: `@flutter_layered_architecture/docs/layered_architecture_yaml.ja.md`
* 依存方向 lint: `flutter-layered-architecture-linter-rule-architecture-layer-dependency`
* 実装依存 lint: `flutter-layered-architecture-linter-rule-architecture-implementation-dependency`
