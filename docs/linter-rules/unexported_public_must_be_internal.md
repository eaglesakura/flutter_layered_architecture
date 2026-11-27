# unexported_public_must_be_internal

Public symbols not exported from a `lib/` barrel (`library;`) must be annotated with `@internal` or be private.

## Details

DO mark public top-level symbols that are not part of the package public surface with `@internal`, or make them private. The public surface is the `exportNamespace` of barrel files: `lib/*.dart` files that declare `library;` (named `library ...;` also counts). Packages with no such barrel are skipped.

Covered symbols include public top-level `class` / `enum` / `mixin` / named `extension` / `extension type` / function / variable / `typedef`. Files that are `part of` another library and paths under `test/` are skipped. Severity is WARNING.

Related annotation: `@internal` (`package:meta`).

BAD:

```dart
// lib/src/hidden_helper.dart (not exported from a barrel)
final class HiddenHelper {
  const HiddenHelper();
}
```

GOOD:

```dart
// lib/src/hidden_helper.dart
@internal
final class HiddenHelper {
  const HiddenHelper();
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
// ignore: flutter_layered_architecture_lint/unexported_public_must_be_internal
```
