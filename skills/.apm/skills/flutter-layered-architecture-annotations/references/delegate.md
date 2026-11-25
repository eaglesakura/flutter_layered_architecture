# `@delegate`

単一処理を切り出したクラスに付与する。ViewModel / Stateful のメソッド本体はここに委譲する。

## いつ付けるか

* `@stateful` / `@viewModel` のインスタンス処理を切り出すとき
* Repository 実装など、状態更新の 1 操作をクラスに閉じるとき

## 付与先

* **型**（`final class` など）
* バレル `library` には付けない

## 必須併記

* `@internal`（`package:meta`）を併記する

## 付与後に効く Lint

| Lint code | 要点 |
| --- | --- |
| `delegate_execute_method` | インスタンスメソッドはちょうど 1 つで名前は `execute` |
| `delegate_immutable` | フィールドは `final`/`const`、`const` コンストラクタあり |
| `delegate_internal` | `@internal` 併記 |
| `delegate_no_nested_delegate` | 別 `@delegate` を受け取らない・生成しない |
| `delegate_no_usecase_instantiation` | `@usecase` 型を内部生成しない（注入する） |

呼び出し側（`@stateful` / `@viewModel`）では `stateful_methods_use_delegate` も効く。

詳細は次の SKILL を正とする。

* `flutter-layered-architecture-linter-rule-delegate-execute-method`
* `flutter-layered-architecture-linter-rule-delegate-immutable`
* `flutter-layered-architecture-linter-rule-delegate-internal`
* `flutter-layered-architecture-linter-rule-delegate-no-nested-delegate`
* `flutter-layered-architecture-linter-rule-delegate-no-usecase-instantiation`
* `flutter-layered-architecture-linter-rule-stateful-methods-use-delegate`

## 推奨形

* 命名は処理内容が分かる名前（画面なら `OnAddTodoDelegate` など）
* 依存（Usecase・`MutableStateStream` など）はコンストラクタで受け取る
* 1 Delegate = 1 `execute`

## 良い例

```dart
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
import 'package:meta/meta.dart';

@internal
@delegate
final class OnAddTodoDelegate {
  const OnAddTodoDelegate({
    required this.state,
    required this.addTodoUsecase,
  });

  final MutableStateStream<TodoListScreenState> state;
  final AddTodoUsecase addTodoUsecase;

  Future<void> execute() async {
    await addTodoUsecase.execute(...);
  }
}
```

## 悪い例

```dart
@delegate // @internal なし → delegate_internal
final class Bad {
  Future<void> run() async {} // execute 以外 → delegate_execute_method
}
```

## DO NOT

* Delegate の中で別 Delegate を new / 引数受け取りしない
* Usecase を Delegate 内で生成しない
* `@stateful` / `@viewModel` の業務メソッドにロジックを直書きしたままにしない（`execute` へ委譲）
