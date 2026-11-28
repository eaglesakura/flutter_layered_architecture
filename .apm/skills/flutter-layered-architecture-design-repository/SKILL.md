---
name: flutter-layered-architecture-design-repository
description: >-
  Flutter Layered Architecture の Repository（data）設計・実装パターン用 SKILL。
  `{機能グループ}Repository`、同一グループ内の複数メソッド、Read/Write・監視、
  状態保持、Request/入出力、interface/_impl 分離、DataInjection、
  Usecase との相互 IF 依存・循環回避、テスト差し替えを扱う。
  「Repository を追加」「watch / Stream」「データ窓口の IF 設計」でも必ず使う。
  Usecase 側は flutter-layered-architecture-design-usecase、
  `@stateful` / `@implementation` / `@injection` は
  flutter-layered-architecture-annotations、
  Provider / injection / Container 結線は flutter-layered-architecture-design-dependency-injection、
  依存方向は flutter-layered-architecture-linter-rule-architecture-layer-dependency、
  実装依存は flutter-layered-architecture-linter-rule-architecture-implementation-dependency、
  package 所属は flutter-layered-architecture-resolve-package-layer、
  Stateful / Delegate の構造は対応する linter-rule-*、
  画面 MVVM は flutter-layered-architecture-design-screen-mvvm を使う。
---
# Flutter Layered Architecture / Repository 設計

Repository は data レイヤーの **データ入出力の窓口**である。
Datasource・DB・外部 API の差異を隠し、Usecase / 上位から同一の IF で扱う。

構造の機械的保証（レイヤー依存・`@implementation` 依存・`@stateful` 制約・Delegate 規約）は Linter / Annotations が担う。
本 SKILL は境界の切り方と、lint が見ない実装パターンに限定する。

正本の例: `@flutter_layered_architecture/example/data/repository/todo/`。

## スコープ外（別正本）

| 関心 | 正本 |
| --- | --- |
| Usecase の切り出し・結線 | `flutter-layered-architecture-design-usecase` |
| Annotation 付与の詳細・連動 lint | `flutter-layered-architecture-annotations`（推奨一覧は本 SKILL「推奨 Annotation」） |
| Provider / injection / Container | `flutter-layered-architecture-design-dependency-injection` |
| レイヤー依存方向 | `flutter-layered-architecture-linter-rule-architecture-layer-dependency` |
| 実装 package への依存制限 | `flutter-layered-architecture-linter-rule-architecture-implementation-dependency` |
| package 所属 | `flutter-layered-architecture-resolve-package-layer` |
| Stateful / Delegate 診断 | 対応する `flutter-layered-architecture-linter-rule-*` |
| 画面 MVVM | `flutter-layered-architecture-design-screen-mvvm` |
| Dart コーディング規約 | `flutter-layered-architecture-coding-rules` |
| workspace | `flutter-layered-architecture-workspace` |

## いつ使うか

* Repository IF / 実装の新規作成・改修
* 機能グループ境界、複数メソッド、Read/Write・監視 API の設計
* 状態保持（`MutableStateStream` 等）と公開ストリーム
* DataInjection・テストでの Mock / Fake 差し替え

## 作業手順

1. **機能グループ**で窓口を切る（認証・設定・Todo など、呼び出し側が 1 IF で扱いたい単位）
2. Read / Write / 監視のどれを公開するか決める（Read-Only・Write-Only も可）
3. `{機能グループ}Repository` と package（`data_repository_*` / `_impl`）を決める
4. 状態を持つなら下表の `@stateful` / `@state` / `@delegate` を付ける
5. IF・実装・injection を整え、必要なら `references/` を読む

## 推奨 Annotation

付与位置・併記・連動 lint の正本は `flutter-layered-architecture-annotations`（各 `references/`）。
ここでは Repository 設計時に **付けるもの** を示す。

| 対象 | Annotation | 備考 |
| --- | --- | --- |
| Repository IF | （なし） | 公開窓口そのものに FLA 型 annotation は付けない |
| 状態を持つ実装型 | `@stateful` | `MutableStateStream` を持つ in-memory 等。画面 VM には使わず `@viewModel` 側へ |
| 状態モデル（`MutableStateStream<T>` の `T`） | `@state` + `@internal` + `@freezed` | ルート `T` に必須。`@entity` と同一型に併記しない |
| 実装内の処理切り出し | `@delegate` + `@internal` | 業務メソッドは `execute` へ委譲（`stateful_methods_use_delegate`） |
| package internal Usecase | `@usecase`（+ 必要なら `@internal`） | 実装内の共通操作。詳細は `design-usecase` |
| 実装バレル（`*_impl`） | `@implementation` | `library;` 付きバレルのみ |
| 結線バレル（`data_injection`） | `@injection` | `library;` 付きバレルのみ。`@implementation` と同一バレルに併記しない |

* 状態を持たない薄い実装でも、バレルの `@implementation` / 結線の `@injection` は付ける
* 詳細は annotations の `stateful.md` / `state.md` / `delegate.md` / `implementation.md` / `injection.md`

## Usecase との違い

| | Usecase | Repository |
| --- | --- | --- |
| 単位 | 1 操作 = 1 型 | 機能グループ = 1 型（**複数メソッド可**） |
| 状態 | 持たない | 持ってよい（監視 API 可） |
| 役割 | アプリの「操作」 | データの「窓口」 |

Usecase の 1 操作原則を Repository に押し付けない。

## 命名・配置

* 型: `{機能グループ}Repository`（例: `TodoRepository`）
* package: `data_repository_${機能}` / 入れ子 `_impl`（`data_repository_${機能}_impl`）
* 結線: `data_injection`（`@injection`）
* 実装バレル: `@implementation`
* 所属の正本は `resolve-package-layer`（名前推測だけで決めない）

## 実装パターン（要約）

* **複数メソッド可**: 同一グループの list / add / update / delete 等を 1 IF にまとめてよい
* **抽象化**: Read/Write・監視・Read-Only・Write-Only いずれも「窓口」として定義してよい
* **状態**: 実装が内部状態を持ち、getter / `*Stream` / `watch*` で公開してよい（example は `@stateful` + `MutableStateStream`）
* **入出力**: ドメイン型直渡しでも Request/Result でも可（契約が明確ならよい）
* **分割**: 実装内は Delegate / package internal Usecase に切ってよい（Delegate lint に従う）
* **依存**: usecase↔data の相互 IF 依存は可。クラス循環は不可

詳細は必要時のみ:

| 参照 | 使うとき |
| --- | --- |
| [package-provider-injection.md](./references/package-provider-injection.md) | IF/_impl の置き場地図（DI 詳細は DI 正本へ） |
| [state-and-io.md](./references/state-and-io.md) | 状態・監視・入出力の形 |
| [testing.md](./references/testing.md) | Mock / Fake / `_testing` |
| `flutter-layered-architecture-design-dependency-injection` | Provider・injection・Container |

## 最小の形（example）

```dart
// IF — FLA 型 annotation なし
abstract interface class TodoRepository {
  static final provider = Provider<TodoRepository>(
    (ref) => throw UnimplementedError('TodoRepository is not bound'),
  );

  Future<List<Todo>> list();
  Future<Todo> add(Todo todo);
  Future<Todo> update(Todo todo);
  Future<void> delete(String id);
}
```

```dart
// 状態を持つ実装
@stateful
final class InMemoryTodoRepository implements TodoRepository {
  const InMemoryTodoRepository({required this.state});
  final MutableStateStream<InMemoryTodoRepositoryState> state;
  // メソッド本体は @delegate へ委譲
}

@internal
@state
@freezed
abstract class InMemoryTodoRepositoryState with _$InMemoryTodoRepositoryState {
  const factory InMemoryTodoRepositoryState({
    required List<Todo> items,
  }) = _InMemoryTodoRepositoryState;
}
```

```dart
// provider / inject の形は design-dependency-injection が正本
// builder.inject(TodoRepository.provider, InMemoryTodoRepository.provider);
```

## Repository ↔ Usecase

* 同レベルのため相互の **インターフェース** 依存は可
* **クラス循環は不可**。`Provider.dependencies` で依存を明示する
* 実装 package 同士の密結合や、公開 IF への SDK リークを避ける
* Usecase 側の切り出し・結線は `design-usecase`

## ナレッジベース

### DO: 機能グループで 1 Repository にまとめる

* 呼び出し側が「このデータ領域」を 1 IF で扱えるようにする

### DO: IF と実装を package で分ける

* 差し替えと循環防止。結線は `data_injection`

### DO NOT: Usecase の 1 操作原則を Repository に適用する

* グループ内の複数メソッドは意図した設計である

### DO NOT: Linter / Annotations が見る構造を本 SKILL に再掲する

* `@stateful`・依存方向・Delegate 規約は各正本へ
