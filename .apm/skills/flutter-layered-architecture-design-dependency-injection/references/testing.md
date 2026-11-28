# テストでの差し替え

Unit Test ハーネス（`testing_core` / `testing_injection` / `_test` の置き場・実体優先）の正本は
`flutter-layered-architecture-design-test`。本ファイルは **Provider 差し替えの形** に限定する。

## 原則

* 命名: `_test`（Unit Test 専用・leaf）／`_testing`（レイヤー・責務内サポート）／`testing_`（横断共有）。正本: `flutter-layered-architecture-design-test`
* 本番 package は `_test` を dependencies / dev_dependencies に載せない（lint: `architecture_unit_test_package_dependency`）。`_testing` / `testing_*` も本番からは載せない（規約）
* テストは本番と同じ IF `provider` を、Fake / Mock / テスト用 Impl で override する
* アプリ全体のテスト用集約（例: `testing_injection`）を app 外に置いてよい
* ロジックは実体 DI を優先し、Mock は再現できない外部や故障注入に限る（詳細は `design-test`）

## 方法

**Provider 同士の inject（推奨の対称形）**

```dart
builder.inject(TodoRepository.provider, FakeTodoRepository.provider);
```

**固定値**

```dart
builder.injectValue(TodoRepository.provider, mockTodoRepository);
```

**素の Override**

```dart
builder.addOverrides([
  TodoRepository.provider.overrideWithValue(mockTodoRepository),
]);
```

いずれも「呼び出し側は IF `provider`」を崩さない。

## 配置の目安

* 薄い Mock で足りる → テストファイル内、または既存 `*_testing`（`endsWith('_testing')`）
* 厚い Fake / 共通初期化 → `{feature}_testing`（責務内）や `testing_injection`（横断）
* app の本番 `inject()` をテストから import して流用すると、実装モジュールへの暗黙参照が広がりやすい。必要ならテスト専用の結線を別途持つ（アプリの `testing_injection` コメントがその例）

## DO / DO NOT

### DO

* IF `provider` を差し替え口にする
* 本番 injection とテスト injection で同じ IF 一覧を意識する（抜けは UnimplementedError で気づける）

### DO NOT

* 本番 IF package からテスト実装を dependencies に足す
* テストのためだけに呼び出し側を実装型へ書き換える
