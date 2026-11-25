# `@usecase`

1 操作を表す Usecase の interface（および必要なら実装）に付与する。

## いつ付けるか

* Usecase の公開 interface を新規作成・改修するとき
* 「1 ユースケース = 1 操作」として lint で構造を固定したいとき

## 付与先

* **型**（`abstract interface class` / `class` など）
* バレル `library` には付けない

## 必須併記

* なし（`@internal` は役割次第。未 export の公開型なら file_layout 側の `@internal` が別途必要になりうる）

## 付与後に効く Lint

| Lint code | 要点 |
| --- | --- |
| `usecase_single_method` | public インスタンスメソッドは高々 1 |
| `usecase_method_signature` | そのメソッドは引数あり・非 void |
| `usecase_immutable` | フィールドは `final`/`const`、`const` コンストラクタあり |

詳細は次の SKILL を正とする。

* `flutter-layered-architecture-linter-rule-usecase-single-method`
* `flutter-layered-architecture-linter-rule-usecase-method-signature`
* `flutter-layered-architecture-linter-rule-usecase-immutable`

## 推奨形

* メソッド名は原則 `execute`
* 入出力は Request / Result（または単一戻り値）に寄せる
* interface と実装は別 package に分けることが多い

## 良い例

```dart
import 'package:flutter_layered_architecture_annotations/flutter_layered_architecture_annotations.dart';

@usecase
abstract interface class AddTodoUsecase {
  const AddTodoUsecase();

  Future<Todo> execute(AddTodoRequest request);
}
```

## 悪い例

```dart
@usecase
abstract interface class TodoUsecase {
  Future<Todo> add(AddTodoRequest request);
  Future<void> delete(String id); // → usecase_single_method
}
```

## DO NOT

* 複数操作を 1 つの `@usecase` に詰めない（分割する）
* `@delegate` 内で `@usecase` 型を `new` しない（コンストラクタ注入）。関連: `delegate_no_usecase_instantiation`
