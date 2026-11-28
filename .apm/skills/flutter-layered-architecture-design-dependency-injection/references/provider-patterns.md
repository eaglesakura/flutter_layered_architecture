# Provider パターン（IF / 実装）

本ファイルは `static final provider` の書き方に限定する。
切り出し単位は各 design SKILL、annotation は `flutter-layered-architecture-annotations` が正本。

## IF 側（stub）

未結線のまま読まれると失敗するようにする。メッセージに型名を入れて原因を追いやすくする。

```dart
static final provider = Provider<TodoRepository>(
  (ref) => throw UnimplementedError('TodoRepository is not bound'),
);
```

```dart
static final provider = Provider<AddTodoUsecase>(
  (ref) => throw UnimplementedError('AddTodoUsecase is not bound'),
);
```

* 型パラメータは **IF 型**
* 呼び出し側（Usecase / ViewModel / 他）は常にこの `provider` を `ref.watch` / `ref.read` する

## 実装側（実体型を推奨）

```dart
static final provider = Provider<AddTodoUsecaseImpl>(
  (ref) => AddTodoUsecaseImpl(ref.watch(TodoRepository.provider)),
  dependencies: [TodoRepository.provider],
);
```

```dart
static final provider = Provider<InMemoryTodoRepository>(
  (ref) {
    final result = InMemoryTodoRepository(
      state: MutableStateStream(
        const InMemoryTodoRepositoryState(items: []),
      ),
    );
    ref.onDispose(result.close);
    return result;
  },
);
```

* 型パラメータは **実装クラス**（`XxxImpl` / `InMemoryXxx` 等）を推奨する
* IF 型で書く（`Provider<AddTodoUsecase>`）ことも動くが、実装 Provider であることが型から分かりにくくなる
* 依存する他 IF は `ref.watch(Other.provider)` し、`dependencies` に列挙する
* 破棄が必要なら `onDispose` / `onDisposeAsync`。長寿命なら `ref.keepAlive()` を検討する

## 結線との関係

```dart
builder.inject(AddTodoUsecase.provider, AddTodoUsecaseImpl.provider);
```

`inject` は stub（IF）を、override（実装）の `ref.watch` 結果で差し替える。
呼び出し側の import / 参照は IF `provider` のままなので、実装 package に依存しなくてよい。

## DO / DO NOT

### DO

* IF / 実装の両方に **class 系の** `static final provider` を置く（トップレベル Provider 禁止。lint: `provider_static_final`）
* 実装は実体型 + 依存明示
* 生成コールバック直下の依存取得は **`ref.watch`**（lint: `provider_ref_watch`）
* `ref.watch` した参照は **`dependencies` に字面どおり列挙**（lint: `provider_dependencies`）
* `ref.watch` が無い宣言（IF stub、`StateStreamProvider...stateBy` のみ等）では `dependencies` を強制しない

### DO NOT

* 呼び出し側で `new XxxImpl(...)`
* IF の stub を本番実装の直接生成にすり替える（injection を飛ばす）
* 実装 Provider だけを公開して IF stub を省略する（上位が実装型に縛られる）
* トップレベルに Provider を置く
* create 直下で `ref.read` により依存を取る
* `ref.watch(X)` があるのに `dependencies` から `X` を省略する
