# Usecase の依存・internal・Fake

## 依存してよいもの

* 他の **Usecase**（公開 IF）
* **Repository** / Datasource（data）
* domain のモデル

usecase と data は同レベルのため、**相互のインターフェース依存は可**。  
**クラス循環は不可**（A→B かつ B→A）。共通処理は第三の Usecase か Repository へ切り出す。

実装 Provider の `dependencies` に監視対象を列挙し、循環を設計時に見える化する。

```dart
dependencies: [
  TodoRepository.provider,
  // 他 Usecase.provider …
],
```

レイヤーを跨ぐ依存の可否は `architecture_layer_dependency` が検査する。

## package internal Usecase

公開 usecase レイヤー以外（例: `data_*_impl`、`screen_feature_*`）の **実装 package 内**に、`@internal` な Usecase を置いてよい。

* 目的: Delegate 間の共通処理の切り出し（Delegate in Delegate の代替）
* 公開 IF / `_impl` 分離や Riverpod Provider は **必須としない**（package 外に出さない）
* 命名は同じく `{動詞}{カテゴリ}Usecase`
* Delegate から `new` せずコンストラクタ注入する（`delegate_no_usecase_instantiation`）

```dart
@internal
final class FetchProfileImageUsecase {
  const FetchProfileImageUsecase({required this.storage});
  final Storage storage;
  Future<ProfileImage> execute() async { /* ... */ }
}
```

## Fake

外部サービスをテストから外すときは Fake を用意する。

* 名前: `{動詞}{カテゴリ}UsecaseFake`
* 配置: 本番実装と同じ `_impl` package に置くことが多い
* Provider を持ち、testing 用 injection で差し替える
* 振る舞い検証が主なら Mock、依存の無効化・no-op が主なら Fake

```dart
final class CrashReportSendUsecaseFake implements CrashReportSendUsecase {
  static final provider = Provider<CrashReportSendUsecase>(
    (ref) => const CrashReportSendUsecaseFake(),
  );
  const CrashReportSendUsecaseFake();

  @override
  Future<void> execute(CrashReportSendRequest request) async {}
}
```

## DO NOT

* Usecase 同士の循環参照
* 本番 package から `_testing` / `_test` / Fake 専用経路へ依存する（正本: `flutter-layered-architecture-design-test`）
* Delegate 内で Usecase を直接 `new` する
