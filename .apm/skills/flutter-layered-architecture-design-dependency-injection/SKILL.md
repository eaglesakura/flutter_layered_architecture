---
name: flutter-layered-architecture-design-dependency-injection
description: >-
  Flutter Layered Architecture の Dependency Injection（Riverpod Provider 結線）正本 SKILL。
  インターフェース／実装の `static final provider`、実体型 Provider、`@implementation` バレル、
  `{レイヤー名}_injection`（`@injection`）での bind、app からの最終 inject 呼び出し、
  ProviderContainer / DependencyBuilder / ProviderContainerBuilder 構築を扱う。
  「DI を足す」「Provider を結線」「inject / override」「UnimplementedError の stub」
  「実装を差し替えたい」「layer injection」「DependencyBuilder」でも必ず使う。
  Unit Test ハーネス（testing_core / testing_injection / _test）は
  flutter-layered-architecture-design-test、
  Usecase / Repository / Screen の切り出し自体は各 design-*、
  `@injection` / `@implementation` 付与詳細は flutter-layered-architecture-annotations、
  実装 package 依存制限は flutter-layered-architecture-linter-rule-architecture-implementation-dependency、
  package 所属は flutter-layered-architecture-resolve-package-layer を使う。
---
# Flutter Layered Architecture / Dependency Injection

Riverpod の **Provider を IF と実装で分け、injection package で結線する**のが本アーキテクチャの DI である。
Usecase / Repository / Navigation など「何を切るか」は各 design SKILL が正本。
本 SKILL は **どう Provider を置き、どう bind し、どこから Container を組むか** に限定する。

正本の例: `@flutter_layered_architecture/example/`（`data_injection` / `usecase_injection` / `foundation_dependency_injection` / `example_app`）。
アプリ規模の呼び出し順の参考: Grand Tube / やさしい漢字の `app/feature/*/lib/src/injection/inject.dart`（Infra → Data → Usecase → Screen）。

## スコープ外（別正本）

| 関心 | 正本 |
| --- | --- |
| Usecase の切り出し・命名・Request | `flutter-layered-architecture-design-usecase` |
| Repository の窓口・状態 | `flutter-layered-architecture-design-repository` |
| Screen MVVM | `flutter-layered-architecture-design-screen-mvvm` |
| 画面遷移 Factory / Launcher | `flutter-layered-architecture-design-screen-navigation` |
| `@injection` / `@implementation` 付与形・併記禁止 | `flutter-layered-architecture-annotations` |
| 実装 package への依存制限 | `flutter-layered-architecture-linter-rule-architecture-implementation-dependency` |
| レイヤー依存方向 | `flutter-layered-architecture-linter-rule-architecture-layer-dependency` |
| package 所属 | `flutter-layered-architecture-resolve-package-layer` |
| Unit Test ハーネス（testing_core / injectForTesting） | `flutter-layered-architecture-design-test` |
| Dart コーディング規約 | `flutter-layered-architecture-coding-rules` |

## いつ使うか

* IF / 実装に `static final provider` を足す・直す
* `{レイヤー}_injection` で `inject(IF.provider, Impl.provider)` する
* app からレイヤー injection を呼び、`ProviderContainer` を組む
* テストで Fake / Mock を差し替える
* Usecase・Repository・Navigation 設計のあとに結線だけが残っているとき

## 作業手順

1. IF に stub `provider`（未結線は `UnimplementedError`）を置く
2. 実装に **実体型** `Provider<XxxImpl>` を置き、`ref.watch` と `dependencies` で依存を明示する
3. 実装バレル（`library;`）に `@implementation` を付ける
4. 同レイヤーの `{レイヤー名}_injection`（`@injection`）で IF → 実装を bind する
5. **app** がレイヤー injection を呼び、Container を `build` して `UncontrolledProviderScope` 等へ渡す
6. 細部は必要時だけ `references/` を読む

## 全体像

```text
IF package          … Xxx.provider → UnimplementedError（呼び出し側は常に IF.provider）
_impl package       … XxxImpl.provider → 実体（Provider<XxxImpl>）。バレル @implementation
{layer}_injection   … builder.inject(Xxx.provider, XxxImpl.provider)。バレル @injection
app                 … 各 layer injection を呼び、builder.build() → ProviderScope
```

Flutter では入口（`main` / テストハーネス）が Container を持つ必要があるため、
**最終的な inject 呼び出しと `build` は app（またはテスト用集約）が行う**。
レイヤーごとの結線一覧は `{レイヤー名}_injection` に寄せ、app は順序付きでそれを呼ぶだけにする。

推奨の呼び出し順（下位 → 上位）:

1. Infra（初期化を含むものがあれば先）
2. Data
3. Usecase
4. Screen（release → 必要なら debug）

## Provider の形（要約）

**IF（stub）**

```dart
static final provider = Provider<AddTodoUsecase>(
  (ref) => throw UnimplementedError('AddTodoUsecase is not bound'),
);
```

**実装（実体型を推奨）**

```dart
static final provider = Provider<AddTodoUsecaseImpl>(
  (ref) => AddTodoUsecaseImpl(ref.watch(TodoRepository.provider)),
  dependencies: [TodoRepository.provider],
);
```

* 呼び出し側は常に **IF の `provider`** を `watch` / `read` する
* 実装側の型パラメータは **実装クラス**（`Provider<XxxImpl>`）を推奨する。`inject` は `T2 extends T` で結線できる
* 必要なら `ref.keepAlive()` / `onDispose` / `onDisposeAsync`
* 呼び出し側で `new XxxImpl(...)` しない

詳細: [provider-patterns.md](./references/provider-patterns.md)

## `{レイヤー名}_injection` と app

* package 名の目安: `data_injection` / `usecase_injection` / `infra_*_injection` など（所属は `resolve-package-layer`）
* バレルは `@injection` + `library;`。`@implementation` と同一バレルに併記しない
* bind の核:

```dart
builder.inject(TodoRepository.provider, InMemoryTodoRepository.provider);
builder.inject(AddTodoUsecase.provider, AddTodoUsecaseImpl.provider);
```

* app はレイヤー bindings を順に呼び、`builder.build()` する（example の `ExampleDependencyInjection` + `main.dart`）

詳細: [injection-packages.md](./references/injection-packages.md)

## Container 構築

* 推奨: `riverpod_container_builder` の `ProviderContainerBuilder`（`inject` / `injectValue`）
* プロジェクト固有ラッパ（example / アプリの `DependencyBuilder`）があってもよい。必須ではない
* 任意の手段で `ProviderContainer` を組み立ててよいが、**IF stub を実装 Provider で override する**契約は同じ

詳細: [container-build.md](./references/container-build.md)

## テスト差し替え

* 本番と同じ IF `provider` に対し、Fake / Mock の Provider または `injectValue` で差し替える
* 本番 package は `_testing` に依存しない。テスト集約は app 外（例: `testing_injection`）に置いてよい

詳細: [testing.md](./references/testing.md)

## 他 design SKILL との役割分担

| 作業 | 先に読む | DI 部分 |
| --- | --- | --- |
| Usecase 追加 | `design-usecase` | 本 SKILL（Provider・usecase_injection・app） |
| Repository 追加 | `design-repository` | 本 SKILL（Provider・data_injection・app） |
| 画面遷移 IF / Factory | `design-screen-navigation` | 本 SKILL（Factory 等の Provider 結線） |
| Annotation の付け方だけ | `annotations` | 本 SKILLは「いつ・どこで結線するか」 |

Usecase / Repository スキル側の package・Provider 案内は、本 SKILL への誘導に留めている。

## ナレッジベース

### DO: IF と実装の両方に `provider` を置く

* IF は未結線失敗、実装は実体。結線は injection が担う

### DO: 実装 Provider は実体型にする

* `Provider<XxxImpl>` を推奨。呼び出しは IF `provider` 経由のまま

### DO: レイヤー結線は `{layer}_injection`、最終呼び出しは app

* Flutter の入口制約を守りつつ、実装依存を injection に閉じる

### DO NOT: app や IF package から `@implementation` を直接 dependencies に足す

* `architecture_implementation_dependency` の対象。同レイヤー `@injection` 経由にする

### DO NOT: `@injection` と `@implementation` を同一バレルに併記する

* both は warning になり依存検査が止まる

### DO NOT: 呼び出し側で実装を `new` する

* 差し替えと循環回避のため、常に Provider 経由
