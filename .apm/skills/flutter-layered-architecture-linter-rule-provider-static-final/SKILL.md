---
name: flutter-layered-architecture-linter-rule-provider-static-final
description: >-
  Flutter Layered Architecture の linter rule `provider_static_final`。
  検査対象 Provider を class 系型の `static final` に置く（トップレベル禁止）。
  Provider 定義・DI 結線、診断 `provider_static_final` の修正、規約に沿った設計では必ず使う。
  プラグイン `flutter_layered_architecture_lint`（analysis_server_plugin）と対になる。
---
# Provider は class 系の `static final`（`provider_static_final`）

検査対象の Provider 宣言を、class 系型の `static final` メンバに置く。

診断は analyzer プラグイン `flutter_layered_architecture_lint` が WARNING として報告する。

## いつ使うか

* `provider_static_final` 診断の修正・抑制判断
* IF / 実装 / Screen の `static final provider` 定義
* 関連ルール（`provider_ref_watch`, `provider_dependencies`）と合わせて設計するとき

## 関連アノテーション

* なし（本ルールは annotation 非依存）

## 推奨設計

* `class` / `final class` / `abstract class` / `abstract interface class` / `mixin class` の `static final` に置く
* トップレベル Provider を増やさない
* `mixin` / `enum` / `extension` / `extension type` メンバには置かない

## ルールが検証すること

* トップレベルの provider-like 宣言 → WARNING
* class 系以外の宿主、または非 `static final` の provider-like フィールド → WARNING

## 良い例

```dart
abstract interface class TodoRepository {
  static final provider = Provider<TodoRepository>(
    (ref) => throw UnimplementedError('TodoRepository is not bound'),
  );
}
```

## 悪い例

```dart
final todoRepositoryProvider = Provider<TodoRepository>(
  (ref) => throw UnimplementedError(),
); // → provider_static_final
```

## 抑制コメント

```dart
// ignore: flutter_layered_architecture_lint/provider_static_final
```

## 関連

* プラグイン有効化: ワークスペースルート `analysis_options.yaml` の top-level `plugins:`
* 関連 linter rule: `provider_ref_watch`, `provider_dependencies`
* DI 設計: `flutter-layered-architecture-design-dependency-injection`
