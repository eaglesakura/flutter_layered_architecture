# Unit Test のファイルレイアウト

## 推奨配置

アプリ規模の workspace では、テストサポートを **testing レイヤー**（または同等の path_prefix）に寄せる。

```text
app_packages/testing/          # または example/testing/ 等（layered_architecture.yaml の testing）
├── core/                      # testing_core
│   ├── lib/
│   │   ├── testing_core.dart              # barrel（export）
│   │   └── src/
│   │       └── test_context_extensions.dart
│   └── pubspec.yaml
└── injection/                 # testing_injection
    ├── lib/
    │   ├── testing_injection.dart         # barrel（export）
    │   └── src/
    │       ├── test_context_inject_for_testing.dart
    │       ├── test_context_inject_for_testing.infra.dart   # part
    │       ├── test_context_inject_for_testing.data.dart    # part
    │       └── test_context_inject_for_testing.usecase.dart # part
    └── pubspec.yaml
```

検証対象ごとの Unit Test は **`_test` package**（または feature 配下の `test/`）に置く。

```text
app_packages/usecase/school/
├── lib/                       # usecase_school（本番 IF）
├── _impl/                     # usecase_school_impl
└── _test/                     # usecase_school_test
    ├── test/
    │   └── extract_allowed_kanji_usecase_test.dart
    └── pubspec.yaml           # testing_core / testing_injection を依存に含む
```

* package 名の目安: `{対象}_test`（例: `usecase_school_test`）
* 所属レイヤーは `resolve-package-layer` / `layered_architecture.yaml` に従う（testing レイヤーは任意レイヤーから参照してよい定義が多い）

## 依存方向

```text
本番 IF / _impl  ←──  _test
testing_core     ←──  testing_injection  ←──  _test
本番 IF / _impl  ←──  testing_injection   （結線のため。app には依存しない）
```

* 本番 → testing / `_test` は禁止
* `testing_injection` → app の本番 `inject()` は禁止（同等バインドをテスト側で持つ）

## `_testing` との違い

| package | 役割 |
| --- | --- |
| `testing_core` | 全 Unit Test 共通の TestContext 拡張 |
| `testing_injection` | アプリ横断のテスト用 DI 一括結線 |
| `{feature}_testing` | 厚い Testing\* 実装（認証フロー等、Mock では読めないときだけ） |
| `{feature}/_test` | その feature のテストコード置き場 |

## Screen 等で `test/` を package 直下に置く場合

`_test` 入れ子が無い既存 package では `lib/` と同階層の `test/` でもよい。
その場合も **依存に `testing_core` / `testing_injection` を足す**点は同じ。
