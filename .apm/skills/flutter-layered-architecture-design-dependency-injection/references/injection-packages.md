# `{レイヤー名}_injection` と app 集約

## なぜ分けるか

* `_impl` package への pub 依存は、同一レイヤーの `_injection` package に限定される（`architecture_implementation_dependency`）
* レイヤーごとの結線一覧を `{レイヤー名}_injection` に置くと、app は「呼ぶ順番」だけに集中できる
* Flutter では `main`（やテスト入口）が `ProviderContainer` を保持するため、**最終呼び出しは app** になる

## レイヤー injection package

配置の目安（example）:

```text
…/data/injection/          # data_injection（pubspec name が _injection で終わる）
…/usecase/injection/       # usecase_injection
```

バレル:

```dart
library;

export 'src/data_injection_bindings.dart';
```

bindings 例:

```dart
final class DataInjectionBindings {
  const DataInjectionBindings();

  void bind(DependencyBuilder builder) {
    builder.inject(TodoRepository.provider, InMemoryTodoRepository.provider);
  }
}
```

```dart
final class UsecaseInjectionBindings {
  const UsecaseInjectionBindings();

  void bind(DependencyBuilder builder) {
    builder.inject(ListTodosUsecase.provider, ListTodosUsecaseImpl.provider);
    builder.inject(AddTodoUsecase.provider, AddTodoUsecaseImpl.provider);
    // …
  }
}
```

* package 名はリポジトリにより多少違う。`{レイヤー}_injection` を推奨し、所属は `resolve-package-layer` で確認する
* Infra のように初期化が必要な場合は、同レイヤーの `*Injection.inject(builder)`（async 可）にまとめてよい（アプリの mobile injection がその例）

## app からの最終呼び出し

example:

```dart
final class ExampleDependencyInjection {
  const ExampleDependencyInjection();

  void bind(DependencyBuilder builder) {
    const DataInjectionBindings().bind(builder);
    const UsecaseInjectionBindings().bind(builder);
  }
}

void main() {
  final builder = DependencyBuilder();
  const ExampleDependencyInjection().bind(builder);
  runApp(
    UncontrolledProviderScope(
      container: builder.build(),
      child: const ExampleApp(),
    ),
  );
}
```

推奨順: Infra → Data → Usecase → Screen。
Grand Tube / やさしい漢字は app 内 `inject.dart` で同順にまとめている。
規模が大きくなったらレイヤー `{layer}_injection` へ切り出し、app はそれを呼ぶ形へ寄せると保守しやすい。

## package 命名（役割）

| 役割 | pubspec `name` | 例 |
| --- | --- | --- |
| 実装 | `_impl` で終わる | `usecase_todo_impl` |
| 結線 | `_injection` で終わる | `data_injection` |

バレルは `library;` + export のみ。library annotation で役割を宣言しない。

## DO / DO NOT

### DO

* レイヤー結線は `{layer}_injection`、最終 `build` は app
* `_impl` への依存は `_injection` に閉じる

### DO NOT

* IF 公開 package や app 本体を `_injection` 名にして実装依存を正当化する（役割が違う）
* 画面や Usecase 実装から他レイヤーの `_impl` を直接 dependencies に足す