---
name: flutter-layered-architecture-dependencies
description: >-
  Flutter Layered Architecture（dart workspace）の外部ライブラリ依存管理 SKILL。
  ルート `pubspec.yaml` に実効バージョンを集約し、worktree 配下は `{pub}: any`、
  追加・版上げ・揃え・`flutter pub outdated` / `pub get`・妥当性検証まで扱う。
  「依存を足す」「outdated」「dependency_overrides」「any に揃える」「パッケージ更新」
  「依存バージョンをルートに寄せる」では必ず使う。
  Flutter SDK 自体の版調査は flutter-maintenance-check-latest-version、
  workspace 構造の把握だけは flutter-layered-architecture-workspace、
  レイヤー境界の依存可否は architecture linter / resolve-package-layer、
  アプリ起動／DTD は flutter-app-debug、Dart 規約のみは coding-rules では使わない。
---
# Flutter Layered Architecture / 依存管理

workspace 全体の **外部 pub 依存**を、ルートで版を揃え、子 package では `any` にして管理する。
Flutter / Dart SDK 本体の版調査は対象外。コマンド例は `flutter` / `dart` 本体で示す（`mise` / `fvm` 等はリポジトリ規約に任せる）。

## スコープ外（別正本）

| 関心 | 正本 |
| --- | --- |
| workspace 地図・package 一覧 | `flutter-layered-architecture-workspace` |
| package 所属レイヤー | `flutter-layered-architecture-resolve-package-layer` |
| レイヤー間依存の可否 | `linter-rule-architecture-layer-dependency` / `architecture-implementation-dependency` |
| Flutter SDK の最新版調査 | `flutter-maintenance-check-latest-version` |
| Dart コーディング規約 | `flutter-layered-architecture-coding-rules` |
| アプリ起動・DTD | `flutter-app-debug` |

## いつ使うか

* 外部ライブラリの追加・削除・版上げ・揃え
* 子 package の `any` 化と、ルートへの版集約
* `flutter pub outdated` → 更新 → `pub get` → 妥当性検証

## 推奨方針（版の置き場所）

**外部 pub の実効バージョンはルート `pubspec.yaml` にだけ書く。worktree 配下では `any` にする。**

| 依存の種類 | worktree（各 package） | ルート |
| --- | --- | --- |
| 外部 pub（pub.dev 等） | `{name}: any` | 実効版を記載（`dependency_overrides` またはルートの `dependencies` / `dev_dependencies`） |
| workspace 内ローカル package | `^x.y.z` + `resolution: workspace` | `workspace:` に列挙（版カタログ対象外） |

```yaml
# ルート pubspec.yaml（版の正本）
dependency_overrides:
  flutter_riverpod: ^3.5.0
  freezed_annotation: ^3.1.0
```

```yaml
# worktree 配下の package（例）
name: usecase_todo
publish_to: "none"
resolution: workspace

dependencies:
  domain_todo: ^0.1.0          # ローカル workspace package
  flutter_riverpod: any        # 外部 pub → any
```

* ルートへの記載は、既存リポジトリが `dependency_overrides` を版カタログにしているならそれを継続してよい
* ルート `dependencies` / `dev_dependencies` に版を書く構成でもよいが、**子はいずれも `any`** に揃える
* 子だけを `^x.y.z` に上げて全体を揃えたつもりにしない（ルートが正本）

詳細は [versioning-policy.md](./references/versioning-policy.md)。

## 作業手順

1. ルート `pubspec.yaml` の版カタログ（overrides / dependencies）と `environment` を読む
2. 追加なら依存名と用途を決め、**ルートに版を書き、使う package 側は `any`** で列挙する
3. 更新なら `flutter pub outdated`（必要なら `--json`）で Resolvable を見る
4. ルートの版だけを更新する（子の `any` は触らない）
5. `flutter pub get`（必要なら app package でも）し、analyze / test / 必要なら build で妥当性を確認する
6. 失敗時は [add-and-update.md](./references/add-and-update.md) の切り戻し順に従う

## 妥当性の判断

* Analyzer が通る
* 関連テストが通る
* 実施した場合、対象プラットフォームのビルドが通る

## 追加ドキュメント

| 参照 | 使うとき |
| --- | --- |
| [versioning-policy.md](./references/versioning-policy.md) | any / ルート版 / ローカル package の切り分け |
| [add-and-update.md](./references/add-and-update.md) | 追加・outdated・検証・切り戻し |

## ナレッジベース

### DO: 外部 pub の版はルートに集約し、子は `any`

* workspace 全体の実効版を一箇所で揃えるため

### DO: Resolvable を見て上げ、上がらないものは理由付きスキップ

* Latest だけ見て無理に上げると解決不能や実行時破綻につながる

### DO NOT: Flutter SDK のアップグレードと pub 更新を混ぜる

* SDK 版調査は隣接 SKILL

### DO NOT: 子 package だけに `^` 版を散らして「更新した」ことにする

* 実効版の正本はルート。散らすと drift と解決齟齬の温床になる
