import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart';
import 'package:riverpod_container_async/riverpod_container_async.dart';
import 'package:riverpod_container_builder/riverpod_container_builder.dart';

/// Builds a [ProviderContainer] and manages provider overrides.
///
/// Wraps [ProviderContainerBuilder] and always applies
/// [ProviderContainerAsyncHelper.inject] for the example project.
///
/// Example:
/// ```dart
/// final builder = DependencyBuilder();
/// builder.injectValue(MyRepository.provider, mockRepo);
/// final container = builder.build();
/// ```
final class DependencyBuilder {
  final _builder = ProviderContainerBuilder();

  /// Creates a [DependencyBuilder].
  DependencyBuilder();

  /// Adds [overrides] to the builder.
  ///
  /// Example:
  /// ```dart
  /// builder.addOverrides([someProvider.overrideWithValue(value)]);
  /// ```
  void addOverrides(Iterable<Override> overrides) {
    _builder.addOverrides(overrides);
  }

  /// Builds a [ProviderContainer] with registered overrides.
  ///
  /// [parent] optional parent container. When omitted, creates a root container.
  /// Always prepends [ProviderContainerAsyncHelper.inject].
  ///
  /// Example:
  /// ```dart
  /// builder.build();
  /// builder.build(parent: parentContainer);
  /// ```
  ProviderContainer build({
    ProviderContainer? parent,
  }) {
    return ProviderContainer(
      parent: parent,
      overrides: [
        ...ProviderContainerAsyncHelper.inject(),
        ..._builder.overrides,
      ],
    );
  }

  /// Replaces [origin] with the value of [override].
  ///
  /// Example:
  /// ```dart
  /// builder.inject(
  ///   MyRepository.provider,
  ///   MockMyRepository.provider,
  /// );
  /// ```
  void inject<T, T2 extends T>(Provider<T> origin, Provider<T2> override) {
    _builder.inject(origin, override);
  }

  /// Replaces [origin] with a fixed [value].
  ///
  /// Example:
  /// ```dart
  /// builder.injectValue(MyRepository.provider, mockRepo);
  /// ```
  void injectValue<T>(Provider<T> origin, T value) {
    _builder.injectValue(origin, value);
  }

  /// Registers [override] for [provider].
  ///
  /// Example:
  /// ```dart
  /// builder.override(
  ///   MyRepository.provider,
  ///   MyRepository.provider.overrideWith((ref) => mock),
  /// );
  /// ```
  void override<T>(Provider<T> provider, Override override) {
    _builder.override(provider, override);
  }
}
