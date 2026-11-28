---
name: flutter-layered-architecture-workspace
description: >-
  Flutter Layered Architecture の dart workspace 構造を把握する SKILL。
  ルート `pubspec.yaml` の `workspace:`・子 package の `resolution: workspace`・
  app レイヤー（ビルド入口。複数アプリを monorepo 管理しうる）の読み方を適用する。
  「workspace 構成」「package 一覧の見方」「どこで build する？」「モノレポの地図」
  では必ず使う。 package の所属レイヤー判定は
  flutter-layered-architecture-resolve-package-layer、アノテーション付与は
  flutter-layered-architecture-annotations、個別 lint 修正は
  flutter-layered-architecture-linter-rule-*、pub 依存の更新手順は
  flutter-layered-architecture-dependencies、Usecase / Repository / Screen 設計は
  flutter-layered-architecture-design-usecase /
  flutter-layered-architecture-design-repository /
  flutter-layered-architecture-design-screen-mvvm /
  flutter-layered-architecture-design-screen-navigation を使う。
  「〇〇機能のコードどこ？」も、まず本 SKILL の workspace 地図から候補を絞る。
---
# Flutter Layered Architecture / Workspace 構造

dart / Flutter の **workspace モノレポ**として、どの package があり、app レイヤーのどのアプリをビルドするかを把握する。
コマンド例は `flutter` 本体で示す（`mise` / `fvm` 等はリポジトリ規約に任せる）。

正本のレイアウト例は `@flutter_layered_architecture`（ルート `pubspec.yaml` / `example/`）である。
利用側リポジトリではパス接頭辞が違っても、**ルート `workspace:` + 子の `resolution: workspace`** の読み方は同じである。

## スコープ外（別正本）

| 関心 | 正本 |
| --- | --- |
| package の所属レイヤー（`path_prefix`） | `flutter-layered-architecture-resolve-package-layer` |
| アノテーション付与 | `flutter-layered-architecture-annotations` |
| 個別診断コードの修正 | `flutter-layered-architecture-linter-rule-*` |
| Usecase の切り出し・命名 | `flutter-layered-architecture-design-usecase` |
| Repository の窓口・状態 | `flutter-layered-architecture-design-repository` |
| Screen MVVM 設計 | `flutter-layered-architecture-design-screen-mvvm` |
| 画面遷移設計 | `flutter-layered-architecture-design-screen-navigation` |
| Dart コーディング規約 | `flutter-layered-architecture-coding-rules` |
| 外部 pub 依存の追加・版上げ・any 揃え | `flutter-layered-architecture-dependencies` |
| Flutter SDK の最新版調査 | `flutter-maintenance-check-latest-version` |
| `layered_architecture.yaml` スキーマ | `@flutter_layered_architecture/docs/layered_architecture_yaml.ja.md` |
| Markdown 見出し TOC だけの docs 探索 | `markdown-search` |
| 文書内パス表記の実体解決 | `workspace-resolve-file-path` |

## いつ使うか

* ルート `pubspec.yaml` の `workspace:` から package 一覧・配置を読むとき
* 子 package の `resolution: workspace` / `publish_to` の役割を説明するとき
* app レイヤー配下のビルド入口（単一／複数アプリ）を確認するとき
* 「この機能の package / 画面 / usecase はどこ？」と所在を調べるとき（地図として本 SKILL から入る）

## 作業手順

1. リポジトリルートの `pubspec.yaml` を開く
2. `workspace:` ブロックでローカル package 一覧を把握する
3. 必要なら `environment`（sdk / flutter）を確認する
4. ビルド対象が app レイヤー配下のどのアプリかを確認する（複数アプリがありうる）
5. 所属レイヤーが必要なら `flutter-layered-architecture-resolve-package-layer` へ引き継ぐ
6. 依存の **更新作業**に入るなら `flutter-layered-architecture-dependencies` へ引き継ぐ
7. 機能の所在調査なら、`workspace:` で候補 package を絞ったうえで検索し、**確認できたパスだけ**を報告する（想像のディレクトリをツリーに足さない）。1 クラス 1 ファイル前提ならファイル名から責務を推測してよい

## 原則（要約）

### workspace でローカル package を列挙する

* ローカル package はルート `pubspec.yaml` の `workspace:` に載る
* ここが一次の地図である。ディスク全体を無秩序に探す前に一覧を得る

```yaml
# ルート pubspec.yaml（@flutter_layered_architecture の例）
workspace:
  - packages/annotations
  - example/app
  - example/domain/todo
  - example/usecase/todo
  - example/usecase/todo/_impl
  # 以下、ローカル package が列挙される
```

### 子 package は `resolution: workspace` で揃える

* 子は多く `publish_to: "none"` と `resolution: workspace`
* **workspace 内ローカル package** は `^x.y.z` 等で書き、workspace 解決に任せる
* **外部 pub** は子では `any`、実効版はルートに集約する（正本は `flutter-layered-architecture-dependencies`）

```yaml
# 子 package の pubspec.yaml（例）
name: usecase_todo
publish_to: "none"
resolution: workspace

environment:
  sdk: ">=3.14.0 <4.0.0"

dependencies:
  domain_todo: ^0.1.0       # ローカル
  flutter_riverpod: any     # 外部 → any（版はルート）
```

### アプリは app レイヤーでビルドする（慣習）

* ユーザー向けアプリの入口は **app レイヤー**に置く（`layered_architecture.yaml` の `app` / `path_prefix`）
* 1 workspace に複数アプリを並べてよい。ビルド対象は「app レイヤー配下のどの package か」で選ぶ
* 本リポジトリの example では `example/app` が app レイヤー。利用側では `app/` 配下に複数 package を置く形などがありうる

```bash
# app レイヤー配下のビルド対象を選ぶ（単一でも複数でも同じ）
cd example/app            # 例: 本リポジトリ
# cd app/yasashii_kanji   # 例: 複数アプリ monorepo
flutter build ...
```

### レイヤー名を推測可能な package 名を推奨する

* package 名は、所属レイヤーが読み取れるプレフィックスにする（例: `usecase_todo`、`domain_todo`、`screen_feature_todo_list`）
* Agent が workspace 一覧だけでもレイヤー候補を立てやすくするためである
* 所属の正本はなお `layered_architecture.yaml` の `path_prefix` と実パスである（`resolve-package-layer`）。名前と配置が食い違うなら配置側を直し、名前も揃える

## ナレッジベース

### DO: まずルート pubspec の workspace を読む

* 公式の package 一覧を得てから、個別ディレクトリへ降りる

### DO: 構造の説明と依存更新・レイヤー判定を混ぜない

* 「どの package があるか／機能の所在の入口／app レイヤーのどれをビルドするか」は本 SKILL
* 「外部依存の追加・版上げ・any 揃え」は `dependencies`
* 「どのレイヤーか」は `resolve-package-layer`

### DO: レイヤー名が分かる package 名にする

* `usecase_*` / `domain_*` / `data_*` のようにプレフィックスを揃えると、Agent の探索・説明が速くなる
* 正本判定は `resolve-package-layer`。名前と `path_prefix` がずれたら両方を一致させる

### DO NOT: Annotation / Linter の規約を本 SKILL に再掲する

* 付与判断は `annotations`、診断修正は各 `linter-rule-*` が正本である
