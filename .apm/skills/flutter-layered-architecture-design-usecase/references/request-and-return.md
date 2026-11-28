# Usecase の入出力（Request / 戻り値）

`usecase_method_signature` は「引数あり・非 void」までを保証する。形の揃え方は本参照。

## Request

* 引数は `*Request` にまとめる（呼び出し側の意図とテストデータを一箇所に）
* 単一パターンなら通常の不変クラスでよい（example の `AddTodoRequest`）
* 複数の入力パターンがあるとき（Dart にオーバーロードが無いため）は **sealed**（freezed 可）にする

```dart
final class AddTodoRequest {
  final String title;
  const AddTodoRequest({required this.title});
}
```

```dart
@freezed
sealed class SearchKanjiRequest with _$SearchKanjiRequest {
  const factory SearchKanjiRequest.byId({required String id}) =
      SearchKanjiRequestById;
  const factory SearchKanjiRequest.byName({required String name}) =
      SearchKanjiRequestByName;
  const SearchKanjiRequest._();
}
```

キャンセルが必要なら Request に `FutureContext?` 等を載せてよい（プロジェクト規約に従う）。

## 戻り値

* ドメイン型をそのまま返してよい（例: `Future<Todo>`）
* 成功／失敗や複数状態を表すなら `*Result`（freezed sealed 等）を使う
* void だけの「副作用のみ」は lint 上避ける。完了を表す Result かドメイン値を返す

```dart
@freezed
sealed class SearchKanjiResult with _$SearchKanjiResult {
  const factory SearchKanjiResult.found({required Kanji kanji}) =
      SearchKanjiResultFound;
  const factory SearchKanjiResult.notFound() = SearchKanjiResultNotFound;
  const SearchKanjiResult._();
}
```

## DO NOT

* 位置引数を増やして「擬似オーバーロード」しない → sealed Request
* Usecase の戻りで UI 専用 Widget モデルを返す（画面固有なら Entity は screen 側）
