---
name: flutter-layered-architecture-linter-rule-architecture-implementation-dependency
description: >-
  linter rule architecture_implementation_dependency。
  バレルの @injection / @implementation に基づき実装 package への依存を制限する。
---
# 実装 package 依存（architecture_implementation_dependency）

## いつ使うか

* @implementation 露出・injection 配線・両 annotation 併記の診断

## ルールが検証すること

### 検査対象

* path_prefix 所属 package のみ。アーキテクチャ外はスキップ
* dependencies + dev_dependencies の直接依存

### 役割判定

* lib/ 直下かつ library ありのバレルのみ
* 名前ベース（injection / implementation）。URI は見ない
* 両方 → warning して依存検査停止

### 依存制約

* @implementation または both への依存は、同一レイヤー名の @injection のみ許可

### 重要度

* すべて warning

## 抑制コメント

// ignore: flutter_layered_architecture_lint/architecture_implementation_dependency

## 関連

* package 所属レイヤーの解決: `flutter-layered-architecture-resolve-package-layer`
* 依存方向 lint: `flutter-layered-architecture-linter-rule-architecture-layer-dependency`
