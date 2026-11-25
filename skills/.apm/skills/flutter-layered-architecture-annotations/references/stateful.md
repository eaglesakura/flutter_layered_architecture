# `@stateful`

`MutableStateStream` を保持する状態保持型に付与する。画面以外（例: in-memory Repository）でも使う。

## いつ付けるか

* `MutableStateStream` をフィールドに持ち、状態更新の中核になる型
* 画面 ViewModel ではないが、同様の状態規約を lint したいとき

画面向け ViewModel は本アノテーションではなく **`@viewModel`** を付ける（`@stateful` の制約は継承される）。

## 付与先

* **型**
* バレル `library` には付けない

## 必須併記

* なし（公開境界は file_layout / `@internal` 側）

## 付与後に効く Lint

| Lint code | 要点 |
| --- | --- |
| `stateful_immutable` | フィールドは `final`/`const`、`const` コンストラクタあり |
| `stateful_has_mutable_state_stream` | `MutableStateStream` フィールドを持つ |
| `stateful_closes_mutable_state_stream` | いずれかの経路で `MutableStateStream.close()` を呼ぶ |
| `stateful_mutable_state_stream_freezed` | `MutableStateStream<T>` の `T` は Freezed 付き class |
| `stateful_methods_use_delegate` | インスタンス／extension メソッドは `@delegate.execute` へ委譲（`close` / `_close` 除く） |

詳細は次の SKILL を正とする。

* `flutter-layered-architecture-linter-rule-stateful-immutable`
* `flutter-layered-architecture-linter-rule-stateful-has-mutable-state-stream`
* `flutter-layered-architecture-linter-rule-stateful-closes-mutable-state-stream`
* `flutter-layered-architecture-linter-rule-stateful-mutable-state-stream-freezed`
* `flutter-layered-architecture-linter-rule-stateful-methods-use-delegate`

## 推奨形

* 状態モデル `T` は Freezed
* 更新ロジックは `@delegate` に切り出す
* ライフサイクル終了時に `close` / `_close` で stream を閉じる

## 良い例

```dart
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';

@stateful
final class InMemoryTodoRepository implements TodoRepository {
  const InMemoryTodoRepository({required this.state});

  final MutableStateStream<InMemoryTodoRepositoryState> state;

  @override
  Future<Todo> add(Todo todo) {
    return AddTodoInMemoryDelegate(state: state).execute(todo);
  }

  Future<void> _close() => state.close();
}
```

## 悪い例

```dart
@stateful
final class Bad {
  Bad(); // const でない・MutableStateStream なし
  var count = 0; // mutable フィールド

  void increment() {
    count++; // delegate 未使用
  }
}
```

## DO NOT

* 画面 ViewModel に `@stateful` だけ付けて `@viewModel` を省略しない（画面は `@viewModel`）
* 状態モデルに Freezed 以外を使わない（lint が要求する）
* 業務メソッドをクラス内に直書きしたままにしない
