# Repository の状態・監視・入出力

## 状態を持ってよい

* Usecase と違い、Repository 実装は内部状態を持ってよい
* 現在値の getter と、変化の `Stream` / `watch*` を公開してよい
* `MutableStateStream` を持つ型は `@stateful` を付け、stateful 系 lint に従う（example の `InMemoryTodoRepository`）

```dart
@stateful
final class InMemoryTodoRepository implements TodoRepository {
  final MutableStateStream<InMemoryTodoRepositoryState> state;
  // list / add / update / delete …
}
```

操作の本体は Delegate に切り出してよい（`delegate_*` lint / `@delegate`）。

## Read / Write / 監視

* Read+Write、Read-Only、Write-Only、監視のみ、いずれも「データの窓口」として定義してよい
* 呼び出し側は DB・リモート・インメモリの差を知らない

## 入出力の形

* ドメイン型の直渡しでよい（example: `Future<Todo> add(Todo todo)`）
* 契約を明示したい操作は `*Request` / `*Result`（freezed・sealed 可）
* Write のみで完了通知だけで足りるなら `Future<void>` + Request でも可
* 監視は `Stream<T>` や `Stream<*Result>`

```dart
@freezed
sealed class PreferenceEditRequest with _$PreferenceEditRequest {
  const factory PreferenceEditRequest.putBool({
    required PreferenceKey key,
    required bool value,
  }) = PreferenceEditRequestPutBool;
  // …
  const PreferenceEditRequest._();
}
```

## DO NOT

* 公開 IF に SDK 固有型を漏らす（実装詳細のリーク）
* 状態更新を Usecase 側のフィールドに持たせる（窓口は Repository）
