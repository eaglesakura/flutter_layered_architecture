---
name: flutter-layered-architecture-linter-rule-architecture-unit-test-package-dependency
description: >-
  Flutter Layered Architecture の linter rule `architecture_unit_test_package_dependency`。
  in-layer package が Unit Test 用 package（*_test）に dependencies / dev_dependencies で
  依存すると WARNING する（leaf 制約）。命名・ブラックボックス運用は design-test、
  レイヤー所属解決は resolve-package-layer を使う。
---
# Unit Test package 依存（`architecture_unit_test_package_dependency`）

`in-layer` の package について、pubspec の直接依存先が Unit Test 用（`endsWith('_test')` かつ単一 path_prefix 所属）なら警告する。

## いつ使うか

* `architecture_unit_test_package_dependency` 診断の修正・抑制判断
* `_test` package を追加・依存するとき
* leaf 制約（本番／他 package から `_test` を dependencies / dev_dependencies に載せない）の確認

## ルールが検証すること

### 検査対象

* 依存元: 単一 `path_prefix` 所属の package のみ（アーキテクチャ外・ambiguous はスキップ）
* 依存: `dependencies` + `dev_dependencies` の直接依存名のみ
* 依存先 Unit Test 用: `name.endsWith('_test')` かつ単一 path_prefix 所属

### 対象外

* `endsWith('_testing')` / `testing_` 接頭辞のみ
* アーキテクチャ外の `*_test` 名
* `dependency_overrides`・間接依存

### 重要度

* すべて WARNING

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/architecture_unit_test_package_dependency
```

## 関連

* 運用規約: `flutter-layered-architecture-design-test`
* package 所属: `flutter-layered-architecture-resolve-package-layer`
* 依存方向: `flutter-layered-architecture-linter-rule-architecture-layer-dependency`
* docs: `@flutter_layered_architecture/docs/linter-rules/architecture_unit_test_package_dependency.ja.md`
