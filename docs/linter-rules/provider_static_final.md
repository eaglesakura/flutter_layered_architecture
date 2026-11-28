# provider_static_final

Keep inspected Provider declarations as `static final` members of a class-like type. Top-level, non-compatible hosts, and non-`static final` fields are WARNING.

## Details

DO place Provider / FutureProvider / StreamProvider / StateNotifierProvider / NotifierProvider / AsyncNotifierProvider / StreamNotifierProvider / StateStreamProvider (including `.autoDispose` / `.stateBy`) on `class` / `final class` / `abstract class` / `abstract interface class` / `mixin class` as `static final`.

DO NOT declare them at library top level, or as members of `mixin` / `enum` / `extension` / `extension type`. Local variables inside methods are out of scope. Severity is WARNING.

BAD:

```dart
final todoRepositoryProvider = Provider<TodoRepository>(
  (ref) => throw UnimplementedError(),
);
```

GOOD:

```dart
abstract interface class TodoRepository {
  static final provider = Provider<TodoRepository>(
    (ref) => throw UnimplementedError('TodoRepository is not bound'),
  );
}
```

## Enable

This rule ships with the `flutter_layered_architecture_lint` analyzer plugin. Enable the plugin in the workspace root `analysis_options.yaml`:

```yaml
plugins:
  flutter_layered_architecture_lint:
    path: packages/lint
```

Requires Dart 3.14+ (Flutter 3.50+). After changing `plugins:`, restart the Dart Analysis Server.

## Suppress

```dart
// ignore: flutter_layered_architecture_lint/provider_static_final
```