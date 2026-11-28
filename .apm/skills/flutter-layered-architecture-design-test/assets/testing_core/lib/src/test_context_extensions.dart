import "dart:io" as io;

import "package:armyknife_test_context/armyknife_test_context.dart";
import "package:flutter/widgets.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:foundation_dependency_injection/foundation_dependency_injection.dart";
import "package:riverpod_container_async/riverpod_container_async.dart";

/// CI環境かどうかを判定する。
///
/// NOTE.
/// プロセス環境変数`CI`の値を参照する。
bool get isCI {
  final v = io.Platform.environment["CI"]?.toLowerCase();
  return switch (v) {
    "true" || "1" || "yes" => true,
    _ => false,
  };
}

/// テスト用Riverpodコンテナ。
///
/// NOTE.
/// [testContext]経由で生成・破棄される。
ProviderContainer get ref => testContext.value(
  ProviderContainer,
  (context) {
    return refBuilder.build();
  },
  onTearDown: (context, container) {
    return container.disposeAsync();
  },
);

/// テスト用DIビルダー。
///
/// NOTE.
/// [testContext]経由で生成される。
/// プロジェクトが `ProviderContainerBuilder` 直使いなら型だけ差し替える。
DependencyBuilder get refBuilder => testContext.value(
  DependencyBuilder,
  (context) {
    WidgetsFlutterBinding.ensureInitialized();
    return DependencyBuilder();
  },
);

/// 実行中[TestContext]。
TestContext get testContext => TestContext.current();
