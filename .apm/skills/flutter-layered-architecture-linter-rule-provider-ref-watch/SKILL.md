---
name: flutter-layered-architecture-linter-rule-provider-ref-watch
description: >-
  Flutter Layered Architecture の linter rule `provider_ref_watch`。
  Provider create コールバック直下では `ref.read` 禁止、`ref.watch` を使う。
  Provider 実装・DI、診断 `provider_ref_watch` の修正では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# Provider create では `ref.watch`（`provider_ref_watch`）

Provider 生成コールバック直下の依存取得は `ref.watch` を使う。`ref.read` は WARNING。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。

## いつ使うか

* `provider_ref_watch` 診断の修正・抑制判断
* 実装 Provider / ViewModel Provider の create コールバック記述
* 関連ルール（`provider_static_final`, `provider_dependencies`）と合わせて設計するとき

## 関連アノテーション

* なし

## 推奨設計

* create 直下の依存は `ref.watch(Other.provider)`
* Widget / ハンドラ内の `ref.read` は本ルール対象外（Screen MVVM の watch/read 節を参照）

## ルールが検証すること

* create コールバック直下の `ref.read(...)` → WARNING
* ネスト関数内・`.stateBy` のみ（create 無し）は対象外

## 良い例

```dart
static final provider = Provider<AddTodoUsecaseImpl>(
  (ref) => AddTodoUsecaseImpl(ref.watch(TodoRepository.provider)),
  dependencies: [TodoRepository.provider],
);
```

## 悪い例

```dart
static final provider = Provider<AddTodoUsecaseImpl>(
  (ref) => AddTodoUsecaseImpl(ref.read(TodoRepository.provider)),
  dependencies: [TodoRepository.provider],
); // → provider_ref_watch
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/provider_ref_watch
```

## 関連

* 関連 linter rule: `provider_static_final`, `provider_dependencies`
* DI 設計: `flutter-layered-architecture-design-dependency-injection`