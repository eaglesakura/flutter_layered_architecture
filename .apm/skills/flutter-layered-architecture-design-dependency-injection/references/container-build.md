# ProviderContainer の構築

結線の契約は「IF stub を実装 Provider で override する」こと。
組み立て手段はプロジェクトに合わせてよい。

## 推奨: `ProviderContainerBuilder`

`riverpod_container_builder` の `ProviderContainerBuilder` は、DI 向けの `inject` / `injectValue` を提供する。

```dart
final builder = ProviderContainerBuilder();
builder.inject(TodoRepository.provider, InMemoryTodoRepository.provider);
builder.inject(AddTodoUsecase.provider, AddTodoUsecaseImpl.provider);
final container = builder.build();
```

* `inject(stub, override)` … stub 参照時に `ref.watch(override)` する
* `injectValue(origin, value)` … 固定値差し替え（テスト向き）
* `add` / `override` / `addOverrides` … 素の Riverpod Override も可

必須ではない。同じ override を手で積んでもよい。

## プロジェクトラッパ（例: `DependencyBuilder`）

example / アプリでは `ProviderContainerBuilder` を内包し、追加の共通 inject
（例: `ProviderContainerAsyncHelper.inject()`）を常に付けるラッパを置くことがある。

```dart
final builder = DependencyBuilder();
const DataInjectionBindings().bind(builder);
const UsecaseInjectionBindings().bind(builder);
final container = builder.build();
```

* ラッパの API が `inject` / `injectValue` を持っていれば、bindings はそれに合わせて書く
* 新規プロジェクトでは `ProviderContainerBuilder` 直使いでも、薄いラッパでもよい

## Flutter への渡し方

```dart
runApp(
  UncontrolledProviderScope(
    container: builder.build(),
    child: const MyApp(),
  ),
);
```

`ProviderScope(overrides: …)` だけでもよいが、レイヤー bindings を再利用するなら
Builder で Container を組んでから Scope に渡す形が扱いやすい。

## DO / DO NOT

### DO

* 本番もテストも「同じ IF provider を差し替える」契約に揃える
* 共通の初期 inject（async helper 等）があるならラッパか先頭 overrides に固定する

### DO NOT

* bindings ごとに別の override 作法を混ぜて追跡不能にする
* Container を組まずに実装をグローバルシングルトンへ逃がす
