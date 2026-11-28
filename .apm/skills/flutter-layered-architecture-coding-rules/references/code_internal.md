# 可視性（`@internal` / テスト用公開）

バレルに export されていない公開トップレベルへの `@internal` 必須は
**`flutter-layered-architecture-linter-rule-unexported-public-must-be-internal`** が正本である。
`@delegate` / `@viewModel` / `@state` / `@entity` の必須 `@internal` 併記は
**`flutter-layered-architecture-annotations`** の各 references を正とする。

本ドキュメントは lint が扱わない **可視性の使い分け** を扱う。

## 使い分け

| 用途 | 付与 |
| --- | --- |
| パッケージ内部専用（未 export の公開シンボル） | `@internal` または private（`_`）※ lint 対象 |
| テストのためだけに公開 | `@visibleForTesting` |
| 継承先からのみ触らせる | `@protected` |

* `@internal` / `@visibleForTesting` / `@protected` は `package:meta/meta.dart`
* 実装詳細（Delegate・内部 State 等）をバレルに載せないなら `@internal`

## 例

```dart
@internal
final strings = _Strings();

final class _Strings {}
```

```dart
@visibleForTesting
factory PreferenceKey.test(String value) => PreferenceKey(value);
```

```dart
class Base {
  @protected
  void onHook() {}
}
```

## ナレッジベース

### DO: 公開したくないものは private か `@internal`

* API 境界をバレル export で明示する

### DO: テスト専用公開には `@visibleForTesting`

* 本番呼び出しを誘発しない印にする

### DO NOT: 未 export の public を annotation 無しで放置する

* 診断と修正は `unexported_public_must_be_internal` へ
