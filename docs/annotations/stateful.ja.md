# @stateful

`MutableStateStream` を保持する状態保持型を示し、`flutter_layered_architecture_lint` が構造を検証できるようにするアノテーションである。

## Details

DO `MutableStateStream` をフィールドに持ち、状態更新の中核になる型（画面以外の in-memory Repository なども含む）に `@stateful` を付与する。フィールドはすべて `final`/`const`、コンストラクタは `const` とする。`MutableStateStream<T>` フィールドを持ち、いずれかの経路で `MutableStateStream.close()` が呼ばれている必要がある（`close` / `_close` による close 呼び出しのみは例外）。ルートの型引数 `T` には `@state` が必須である（Freezed 等のFreezed 等の構造は `@state` 型に対する `state_entity_*` が検査する）。インスタンス／extension メソッドの処理は `@delegate` の `execute` へ委譲する（stream を閉じるだけの `close` / `_close` は例外）。

画面向け ViewModel には本アノテーションではなく `@viewModel` を付ける。`@viewModel` は本制約を継承する。

関連 lint の Severity: WARNING。

BAD:

```dart
@stateful
final class Bad {
  Bad();
  var count = 0;

  void increment() {
    count++;
  }
}
```

GOOD:

```dart
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

## Usage

Import:

```dart
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';
```

付与先: 型。バレル `library` には付けない。

## Related linter rules

* [stateful_immutable](../linter-rules/stateful_immutable.ja.md)
* [stateful_has_mutable_state_stream](../linter-rules/stateful_has_mutable_state_stream.ja.md)
* [stateful_closes_mutable_state_stream](../linter-rules/stateful_closes_mutable_state_stream.ja.md)
* [stateful_mutable_state_stream_state](../linter-rules/stateful_mutable_state_stream_state.ja.md)
* [stateful_methods_use_delegate](../linter-rules/stateful_methods_use_delegate.ja.md)
