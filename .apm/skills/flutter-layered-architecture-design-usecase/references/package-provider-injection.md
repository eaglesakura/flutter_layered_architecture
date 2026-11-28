# Usecase の package・Provider・injection

構造の不変性は `usecase_immutable`、実装 package への依存可否は `@injection` / `architecture_implementation_dependency` が検査する。ここでは配置と結線の型を示す。

## package 配置

```text
…/usecase/todo/                 # usecase_todo（IF）
├── pubspec.yaml
├── lib/
│   ├── usecase_todo.dart       # バレル
│   └── src/…Usecase.dart
└── _impl/                      # usecase_todo_impl（実装）
    ├── pubspec.yaml
    └── lib/
        ├── usecase_todo_impl.dart  # @implementation + library
        └── src/…UsecaseImpl.dart

…/usecase/injection/            # usecase_injection（結線）
└── lib/…                       # @injection + library
```

* IF: `usecase_${機能}`、実装: 入れ子 `_impl`（`usecase_${機能}_impl`）
* 本番コードは `_test` / `_testing` に依存しない
* バレル役割は annotations（`@implementation` / `@injection`）を正とする

## Provider

**IF 側** — 未結線時は失敗させる:

```dart
static final provider = Provider<AddTodoUsecase>(
  (ref) => throw UnimplementedError('AddTodoUsecase is not bound'),
);
```

**実装側** — 実体と依存を明示する:

```dart
final class AddTodoUsecaseImpl implements AddTodoUsecase {
  static final provider = Provider<AddTodoUsecaseImpl>(
    (ref) => AddTodoUsecaseImpl(ref.watch(TodoRepository.provider)),
    dependencies: [TodoRepository.provider],
  );

  final TodoRepository _todoRepository;
  const AddTodoUsecaseImpl(this._todoRepository);

  @override
  Future<Todo> execute(AddTodoRequest request) { /* ... */ }
}
```

* 必要なら `ref.keepAlive()` / `onDisposeAsync` でライフサイクルを扱う
* 取得は常に Provider 経由。`new …UsecaseImpl` を呼び出し側でしない

## injection 結線

example では bindings が IF Provider と実装 Provider を結びつける:

```dart
builder.inject(AddTodoUsecase.provider, AddTodoUsecaseImpl.provider);
```

* 結線専用 package にまとめ、`@injection` を付ける
* テスト用差し替えは `_testing` 等で Fake Provider を inject する

詳細な annotation 規約は `flutter-layered-architecture-annotations` の injection / implementation を読む。
