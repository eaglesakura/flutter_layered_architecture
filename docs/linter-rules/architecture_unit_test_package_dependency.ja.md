# architecture_unit_test_package_dependency

アーキテクチャレイヤー所属の package が、Unit Test 用 package（`*_test`）に `dependencies` または `dev_dependencies` で直接依存すると警告する。

レイヤー所属に使う `layered_architecture.yaml` のスキーマは [layered_architecture_yaml.ja.md](../layered_architecture_yaml.ja.md) を参照する。運用規約（命名・ブラックボックス）は `flutter-layered-architecture-design-test` を参照する。

## Details

DO Unit Test 用 package（`in-layer` かつ pubspec `name.endsWith('_test')`）を依存グラフの **leaf** に保つ。検査対象の依存元は単一 `path_prefix` に所属する package のみである。検査する依存は `dependencies` と `dev_dependencies` の直接依存名のみであり、`dependency_overrides`・間接依存は対象外である。

アーキテクチャ外の依存元、定義不在・YAML 不正、依存元の所属 ambiguous はスキップする（定義まわりは `architecture_layer_dependency` の担当）。依存先が `endsWith('_testing')` や `testing_` 接頭辞のみの場合は本ルールの対象外である。アーキテクチャ外の `*_test` 名も Unit Test 用とみなさない。

Severity は WARNING である。

BAD:

```yaml
# domain_todo (in-layer) が usecase_todo_test に依存
dependencies:
  usecase_todo_test:
    path: ../usecase/todo/_test
```

```yaml
# domain_todo の dev_dependencies に *_test（これも WARNING）
dev_dependencies:
  domain_todo_test:
    path: ./_test
```

```yaml
# leaf 違反: domain_todo_test → other_feature_test
dependencies:
  other_feature_test:
    path: ../other/_test
```

GOOD:

```yaml
# 本番は *_test を載せない。*_testing / testing_* は本ルール対象外
dependencies:
  domain_todo:
    path: ../domain/todo
dev_dependencies:
  test: any
```

## Enable

本ルールは `flutter_layered_architecture_lint` analyzer プラグインに含まれる。ワークスペースルートの `analysis_options.yaml` でプラグインを有効化する:

```yaml
plugins:
  flutter_layered_architecture_lint:
    path: packages/lint
```

Dart 3.14+（Flutter 3.50+）が必要である。`plugins:` を変更したら Dart Analysis Server を再起動する。

## Suppress

```dart
// ignore: flutter_layered_architecture_lint/architecture_unit_test_package_dependency
```
