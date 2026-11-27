# delegate_internal

`@delegate` types must also be annotated with `@internal`.

## Details

DO annotate every `@delegate` type with `@internal` (from `package:meta`) as well. Delegate types are package-internal implementation details and must not be treated as public API.

Severity is WARNING.

Related annotations: `@delegate`, `@internal`.

BAD:

```dart
@delegate
final class OnAddTodoDelegate {
  const OnAddTodoDelegate();

  Future<void> execute() async {}
}
```

GOOD:

```dart
@internal
@delegate
final class OnAddTodoDelegate {
  const OnAddTodoDelegate();

  Future<void> execute() async {}
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
// ignore: flutter_layered_architecture_lint/delegate_internal
```
