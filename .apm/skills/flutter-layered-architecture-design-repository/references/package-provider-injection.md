# Repository の package・Provider・injection

実装 package への依存可否は `@injection` / `architecture_implementation_dependency` が検査する。

## package 配置

```text
…/data/repository/todo/              # data_repository_todo（IF）
├── pubspec.yaml
├── lib/
│   ├── data_repository_todo.dart
│   └── src/todo_repository.dart
└── _impl/                           # data_repository_todo_impl
    ├── pubspec.yaml
    └── lib/
        ├── data_repository_todo_impl.dart  # @implementation
        └── src/…Repository.dart

…/data/injection/                    # data_injection
└── lib/…                            # @injection
```

* IF: `data_repository_${機能}`、実装: 入れ子 `_impl`
* 厚いテスト用実装が必要なときだけ `_testing`（Mock で足りるなら作らない）
* 本番は `_test` / `_testing` に依存しない

## Provider

**IF 側**

```dart
static final provider = Provider<TodoRepository>(
  (ref) => throw UnimplementedError('TodoRepository is not bound'),
);
```

**実装側** — 依存・破棄を明示する:

```dart
static final provider = Provider<InMemoryTodoRepository>(
  (ref) {
    final result = InMemoryTodoRepository(
      state: MutableStateStream(const InMemoryTodoRepositoryState(items: [])),
    );
    ref.onDispose(result.close);
    return result;
  },
);
```

* 必要なら `ref.keepAlive()` / `dependencies` / `onDisposeAsync`
* 呼び出し側は Provider 経由のみ。実装を直接 `new` しない

## DataInjection

```dart
builder.inject(TodoRepository.provider, InMemoryTodoRepository.provider);
```

結線専用 package にまとめ `@injection` を付ける。annotation 詳細は annotations の injection / implementation を正とする。
