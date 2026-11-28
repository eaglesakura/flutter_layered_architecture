# layered_architecture.yaml

## 概要

`layered_architecture.yaml` は、Flutter Layered Architecture における **アーキテクチャレイヤー定義とルール設定** の正本である。

* Analyzer プラグイン（`flutter_layered_architecture_lint`）が package の所属レイヤー・依存方向・ファイル名キーワードなどを解決するときに読む
* 探索は検査対象 package の root から親ディレクトリへ辿り、**最初に見つかった** 本ファイルを適用する
* 正本の例: リポジトリルートの [`layered_architecture.yaml`](../layered_architecture.yaml)

関連する linter ルール:

* [`architecture_layer_dependency`](linter-rules/architecture_layer_dependency.ja.md) — レイヤー所属と依存方向（`level`）
* [`architecture_implementation_dependency`](linter-rules/architecture_implementation_dependency.ja.md) — `_impl` package への依存制限（役割は pubspec `name` サフィックス。所属は本 YAML の `path_prefix` を前提）
* [`architecture_unit_test_package_dependency`](linter-rules/architecture_unit_test_package_dependency.ja.md) — Unit Test 用 package（`*_test`）への依存禁止（leaf）
* [`public_type_file_name`](linter-rules/public_type_file_name.ja.md) — `rules.public_type_file_name.keywords`

## ファイル探索

検査対象 package の package root（`pubspec.yaml` があるディレクトリ）から親へ辿り、最初に見つかった `layered_architecture.yaml` を使う。

* ルートまで無ければ、レイヤー依存系ルールは **warning**（定義不在）とする
* `path_prefix` は、**その定義ファイルがあるディレクトリ** からの相対パスである
* package 実パスは `.dart_tool/package_config.json`（package 名 → root URI）で解決する
* パス比較は separator を正規化し、パス区切り境界を尊重する

## トップレベルスキーマ

トップレベルは map である。認識するキーは次のとおり。

| キー | 必須 | 説明 |
| --- | --- | --- |
| `layers` | はい（レイヤー検査を行う場合） | レイヤー定義のリスト |
| `rules` | いいえ | ルール固有の設定 |

```yaml
layers:
  - domain:
      level: 2
      description: |
        Domainレイヤー.
      path_prefix: example/domain
  - testing:
      description: |
        Unit Testサポート用.
      path_prefix: example/testing

rules:
  architecture_layer_dependency:
    ignore:
      - infra_example_ignore
  architecture_implementation_dependency:
    ignore:
      - infra_example_ignore
  public_type_file_name:
    keywords:
      UseCase: usecase
      ViewModel: viewmodel
```

上記はリポジトリ正本の抜粋である。完全な例は [`layered_architecture.yaml`](../layered_architecture.yaml) を参照する。

## layers

`layers` はリストである。各要素は **単一キーの map**（キーがレイヤー名、値が設定 map）でなければならない。

### レイヤーエントリの形式

```yaml
layers:
  - <layer_name>:
      path_prefix: <相対パス>   # 必須・非空文字列
      level: <正の整数>         # 任意
      description: <文字列>     # 任意（人間向け。パーサは未使用）
```

| フィールド | 必須 | 型・制約 | 説明 |
| --- | --- | --- | --- |
| （キー）レイヤー名 | はい | 文字列 | 診断メッセージ等で使う識別名（例: `usecase`、`domain`） |
| `path_prefix` | はい | 非空文字列 | 定義ファイル所在ディレクトリからの相対パス。配下（または同一）の package が当該レイヤー所属 |
| `level` | いいえ | 正の整数（`> 0`） | 依存方向の比較に使う。未記載なら任意レイヤーと接続可（level 比較対象外） |
| `description` | いいえ | 文字列 | ドキュメント用。lint パーサは読まない |

`level` に `0`・負数・非整数を書くとパース失敗（warning）となる。`path_prefix` 欠落・空も同様である。

### layers の補足

* 利点: ディレクトリ配置とレイヤー境界を機械的に揃え、依存逆転を静的に検出できる
* 注意点: `path_prefix` の重複・包括は事前チェックで warning になる。1 package が複数レイヤーにマッチすることも許可しない
* 適用範囲: いずれかの `path_prefix` に属する package のみがレイヤー検査対象。属さない package はアーキテクチャ外としてスキップする
* 例外: package が無い未使用レイヤー定義は将来予約として許可する。`level` 未記載レイヤーは level 比較の対象外である

### 所属の判定

1. 定義ファイルを探索する（上記「ファイル探索」）
2. `package_config.json` で package 実パスを取る
3. 各レイヤーの `path_prefix` を定義ディレクトリ基準で絶対パス化し、package root がその配下（または同一）か判定する
4. マッチは高々 1 つ。複数マッチは warning とし、当該 package の依存方向検査は行わない

### 依存方向（level）

双方の package が単一レイヤーに所属し、双方に `level` があるとき、依存先の `level` は依存元の `level` **以下**（同レベル含む、`dep.level <= self.level`）でなければならない。違反は [`architecture_layer_dependency`](linter-rules/architecture_layer_dependency.ja.md) の warning である。

* 片方のみ `level` がある依存は比較しない
* いずれの `path_prefix` にも属さない依存先は比較しない
* 同レベル間の循環は本 YAML / 当該ルールでは検出しない

## rules

`rules` は任意の map である。現状、次のサブルール設定を認識する。

### rules.architecture_layer_dependency.ignore

特定 package 名だけ **依存方向（level）検査**をスキップする。

```yaml
rules:
  architecture_layer_dependency:
    ignore:
      - infra_example_ignore
```

* 要素は pubspec の package 名。**完全一致**のみ（部分一致・正規表現なし。trim しない）
* 一致した **依存元** の level 違反検査のみスキップする
* 定義不在・YAML 不正・`path_prefix` 重複／包括などの定義スコープ診断は、ignore していても報告する
* 依存先が ignore に載っていても、依存元が ignore に無ければ通常どおり検査する
* 未記載・空リスト・親キー欠落は「設定なし」と同等
* 形式不正、または `package_config.json` で解決できない名前が 1 件でもあれば WARNING（記述エラー）とし、ignore スキップは適用しない

詳細は [`architecture_layer_dependency`](linter-rules/architecture_layer_dependency.ja.md) を参照する。

### rules.architecture_implementation_dependency.ignore

特定 package 名だけ **`_impl` 依存検査**をスキップする。

```yaml
rules:
  architecture_implementation_dependency:
    ignore:
      - infra_example_ignore
```

* 要素は pubspec の package 名。**完全一致**のみ（部分一致・正規表現なし。trim しない）
* 一致した **依存元** の `_impl` 依存検査のみスキップする
* 定義スコープ診断は ignore していても報告する
* 依存先が ignore に載っていても、依存元が ignore に無ければ通常どおり検査する
* 未記載・空リスト・親キー欠落は「設定なし」と同等
* 形式不正、または `package_config.json` で解決できない名前が 1 件でもあれば WARNING（記述エラー）とし、ignore スキップは適用しない

詳細は [`architecture_implementation_dependency`](linter-rules/architecture_implementation_dependency.ja.md) を参照する。

### rules.public_type_file_name.keywords

型名の CamelCase セグメントを、期待ファイル名トークンへ置換する。

```yaml
rules:
  public_type_file_name:
    keywords:
      UseCase: usecase
      ViewModel: viewmodel
```

* キーは置換対象の CamelCase（例: `UseCase`）、値はファイル名用トークン（例: `usecase`）
* YAML 記載順で適用し、先勝ちである
* マッチは大文字小文字を厳密に見る（`UseCase` は型セグメント `Usecase` に効かない）
* `rules` / `keywords` が無い、または空なら、従来どおりの PascalCase → snake 変換のみ
* 不正・欠落エントリはスキップし、空リスト扱い（keywords 欠落では WARNING を出さない）

例: `UseCase: usecase` があるとき、型 `AddTodoUseCase` は `add_todo_usecase.dart` を期待する（未設定なら `add_todo_use_case.dart`）。

詳細は [`public_type_file_name`](linter-rules/public_type_file_name.ja.md) を参照する。

## ナレッジベース

### DO: path_prefix を重複・包括させない

* レイヤー境界は兄弟ディレクトリで切り、親子を別レイヤーにしない

```yaml
# DO: 兄弟プレフィックス
layers:
  - data:
      level: 4
      path_prefix: example/data
  - usecase:
      level: 4
      path_prefix: example/usecase
```

### DO NOT: 下位 path_prefix を別レイヤーとして併記する

* 理由: 包括として事前チェック warning になり、配下 package は複数レイヤーマッチにもなりうる

```yaml
# DO NOT: example/data が example/data/repository を包括する
layers:
  - data:
      level: 4
      path_prefix: example/data
  - data_repo:
      level: 4
      path_prefix: example/data/repository
```

### DO: 任意接続レイヤーは level を省略する

* テスト支援など、どのレイヤーとも接続してよい package 群は `level` を書かない

```yaml
layers:
  - testing:
      path_prefix: example/testing
```

### DO NOT: level に 0 以下や非整数を書く

* 理由: パース失敗となり、依存方向検査が行われない

## 参考リンク

* リポジトリ正本: [`layered_architecture.yaml`](../layered_architecture.yaml)
* package 所属レイヤーの解決（Agent SKILL）: `flutter-layered-architecture-resolve-package-layer`
* ルール詳細（依存方向）: [`architecture_layer_dependency`](linter-rules/architecture_layer_dependency.ja.md)
* ルール詳細（実装依存）: [`architecture_implementation_dependency`](linter-rules/architecture_implementation_dependency.ja.md)
* ルール詳細（ファイル名）: [`public_type_file_name`](linter-rules/public_type_file_name.ja.md)
