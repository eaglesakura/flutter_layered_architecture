import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

// NOTE.
// 以下は概念例。プロジェクトの ScreenState / Delegate / Providers / ScreenImpl に差し替える。
// import "package:screen_feature_example/...";

/// [ExampleScreenState] から Golden 対象の [ExampleScreenImpl] を構築する（概念例）。
///
/// 本番と同じ [ExampleScreenStateToEntityDelegate] で Entity に変換し、
/// entity Provider を override して ViewModel なしで描画する。
Widget buildGoldenScreen({
  required ExampleScreenState state,
  ExampleScreenStateToEntityDelegate delegate =
      const ExampleScreenStateToEntityDelegate(),
}) {
  final entity = delegate.execute(state);
  return ProviderScope(
    overrides: [
      ExampleScreenProviders.entity.overrideWithBuild(
        (ref, self) => entity,
      ),
    ],
    child: const ExampleScreenImpl(),
  );
}

/// loading 状態の Golden 用 State（概念例）。
ExampleScreenState newGoldenScreenStateLoading() {
  return const ExampleScreenState.loading();
}

/// loaded 状態の Golden 用 State（概念例）。
ExampleScreenState newGoldenScreenStateLoaded() {
  return const ExampleScreenState.loaded(body: "…");
}

/// error 状態の Golden 用 State（概念例）。
ExampleScreenState newGoldenScreenStateError() {
  return const ExampleScreenState.error(message: "load failed");
}

// --- 以下は型のプレースホルダ（実プロジェクトでは本番型を import する） ---

sealed class ExampleScreenState {
  const ExampleScreenState();
  const factory ExampleScreenState.loading() = _Loading;
  const factory ExampleScreenState.loaded({required String body}) = _Loaded;
  const factory ExampleScreenState.error({required String message}) = _Error;
}

final class _Loading extends ExampleScreenState {
  const _Loading();
}

final class _Loaded extends ExampleScreenState {
  const _Loaded({required this.body});
  final String body;
}

final class _Error extends ExampleScreenState {
  const _Error({required this.message});
  final String message;
}

sealed class ExampleScreenEntity {
  const ExampleScreenEntity();
}

final class ExampleScreenStateToEntityDelegate {
  const ExampleScreenStateToEntityDelegate();

  ExampleScreenEntity execute(ExampleScreenState state) {
    // 本番 Delegate と同じ分岐を使う。
    return switch (state) {
      _Loading() => const _EntityLoading(),
      _Loaded(:final body) => _EntityLoaded(body: body),
      _Error(:final message) => _EntityError(message: message),
    };
  }
}

final class _EntityLoading extends ExampleScreenEntity {
  const _EntityLoading();
}

final class _EntityLoaded extends ExampleScreenEntity {
  const _EntityLoaded({required this.body});
  final String body;
}

final class _EntityError extends ExampleScreenEntity {
  const _EntityError({required this.message});
  final String message;
}

final class ExampleScreenProviders {
  static final entity = Provider<ExampleScreenEntity>(
    (ref) => throw UnimplementedError("override in golden"),
  );
  const ExampleScreenProviders._();
}

final class ExampleScreenImpl extends ConsumerWidget {
  const ExampleScreenImpl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = ref.watch(ExampleScreenProviders.entity);
    return Scaffold(
      body: switch (entity) {
        _EntityLoading() => const CircularProgressIndicator(),
        _EntityLoaded(:final body) => Text(body),
        _EntityError(:final message) => Text(message),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
