---
name: flutter-layered-architecture-linter-rule-architecture-implementation-dependency
description: >-
  linter rule architecture_implementation_dependency。
  pubspec name の _injection / _impl サフィックスに基づき _impl package への依存を制限する。
---
# 実装 package 依存（architecture_implementation_dependency）

## いつ使うか

* `_impl` package への露出・injection 配線の診断
* `rules.architecture_implementation_dependency.ignore` の記述エラー修正

## ルールが検証すること

### 検査対象

* path_prefix 所属 package のみ。アーキテクチャ外はスキップ
* dependencies + dev_dependencies の直接依存

### 役割判定

* pubspec の `name` のみ（`endsWith('_injection')` / `endsWith('_impl')`）
* `_injection` を先に判定（`foo_impl_injection` → injection）
* バレル・library annotation は見ない

### 依存制約

* `_impl` への依存は、同一レイヤー名の `_injection` のみ許可

### ignore

* `rules.architecture_implementation_dependency.ignore` は layer-ignore と同セマンティクス（依存元の `_impl` 依存検査のみスキップ）
* 未解決名・形式不正は WARNING（記述エラー）とし、スキップは無効

### 重要度

* すべて warning

## 抑制コメント

// ignore: flutter_layered_architecture_lint/architecture_implementation_dependency

## 関連

* package 所属レイヤーの解決: `flutter-layered-architecture-resolve-package-layer`
* 依存方向 lint: `flutter-layered-architecture-linter-rule-architecture-layer-dependency`
* ドキュメント: `docs/linter-rules/architecture_implementation_dependency.ja.md`