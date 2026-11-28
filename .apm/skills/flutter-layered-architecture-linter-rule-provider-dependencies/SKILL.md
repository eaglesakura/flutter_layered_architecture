---
name: flutter-layered-architecture-linter-rule-provider-dependencies
description: >-
  Flutter Layered Architecture の linter rule `provider_dependencies`。
  create 直下の `ref.watch(X)` を `dependencies` に字面一致で列挙する。
  Provider 実装・DI、診断 `provider_dependencies` の修正では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# `ref.watch` は `dependencies` に列挙（`provider_dependencies`）

create コールバック直下で `ref.watch(X)` した参照は `dependencies` に字面一致で含める。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。

## いつ使うか

* `provider_dependencies` 診断の修正・抑制判断
* 実装 Provider / ViewModel Provider の `dependencies` 記述
* 関連ルール（`provider_static_final`, `provider_ref_watch`）と合わせて設計するとき

## 関連アノテーション

* なし

## 推奨設計

* `ref.watch` した各参照を `dependencies: [...]` にそのまま書く
* IF stub や `stateBy` のみ（`ref.watch` 無し）では `dependencies` を強制しない
* 余分な dependencies エントリは許容

## ルールが検証すること

* 直下 `ref.watch(X)` があるのに `dependencies` に `X` 字面が無い → WARNING（各 watch 1 件）
* `ref.watch` が 0 件 → 検査しない

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
  (ref) => AddTodoUsecaseImpl(ref.watch(TodoRepository.provider)),
); // → provider_dependencies
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/provider_dependencies
```

## 関連

* 関連 linter rule: `provider_static_final`, `provider_ref_watch`
* DI 設計: `flutter-layered-architecture-design-dependency-injection`