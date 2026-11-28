# View / Widget（Screen・ScreenImpl）

## 分割

* **`{画面名}Screen`**: public の入口。ViewModel の `watch`、`onInitialize`、（任意）event 購読
* **`{画面名}ScreenImpl`**: 見た目。子 Widget もここに寄せる
* Screen に `@internal` を付けない（公開入口）

```dart
final class TodoListScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(TodoListScreenViewModel.provider);
    useEffect(() {
      viewModel.onInitialize();
      return null;
    }, [viewModel]);
    return const TodoListScreenImpl();
  }
}
```

## watch / read

* **表示に使う値**は `build` 内で `ref.watch`（Entity や `watchBy`）
* **操作・コールバック内**は `ref.read` で ViewModel / Usecase を取る
* 子 Widget の `build` で ViewModel 全体を `watch` しない（Entity のみ）
* 子から `viewModel.onXXXX()` を `build` 中に呼ばない（ハンドラ内で `read`）

## Riverpod

* Provider はクラスの `static final`。グローバルトップレベル Provider を増やさない
* **`@riverpod` コード生成は使わない**（手書き `Provider.autoDispose`）
* `dependencies` を明示する

## Widget 種別

* `HookConsumerWidget` / `ConsumerWidget` / `HookWidget` 等の Stateless 系
* **`StatefulWidget` は作らない**。ローカル UI 一時状態は Hooks、画面状態は ViewModel

## DO NOT

* 画面 package から `go_router` / `Navigator` を直叩きする → `screen-navigation`
* ビジネスロジックを Widget に書く
* 表示状態を `build` 内で `ref.read` する（再描画されない）
