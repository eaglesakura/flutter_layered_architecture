# flutter_layered_architecture_lint

Custom lint rules for Flutter Layered Architecture conventions.

Add this package and `custom_lint` as `dev_dependencies`, then enable the
plugin in `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint
```

Pair with `flutter_layered_architecture_annotations`.

Architecture violations (`@usecase` / `@delegate` / `@stateful`) are reported as
**WARNING**.

## Rules

### File layout

| Lint code | Check |
| --- | --- |
| `one_public_type_per_file` | At most one public named type (`class` / `enum` / `mixin` / named `extension` / `extension type`) per file |
| `public_type_file_name` | When exactly one public type exists, the file name must be its `lower_snake_case` form |

Skipped for `part of` files and paths under `test/`. Private (`_`-prefixed) types and `typedef`s are ignored. Zero public types is allowed.

Helper unit tests (assert runner; `package:test` conflicts with this workspace's `analyzer`/`flutter_test` pins):

```bash
cd packages/lint && dart run test/file_layout_checkers_test.dart
```

### `@usecase`

| Lint code | Check |
| --- | --- |
| `usecase_single_method` | Warns when two or more public instance methods exist |
| `usecase_method_signature` | The single public method has parameters and a non-void return type |
| `usecase_immutable` | All fields are `final`/`const`, and a `const` constructor exists |

### `@delegate`

| Lint code | Check |
| --- | --- |
| `delegate_execute_method` | Declares exactly one instance method named `execute` |
| `delegate_immutable` | All fields are `final`/`const`, and a `const` constructor exists |
| `delegate_internal` | Also annotated with `@internal` |
| `delegate_no_nested_delegate` | Must not accept or instantiate other `@delegate` types |
| `delegate_no_usecase_instantiation` | Must not instantiate `@usecase` types (inject via constructor) |

### `@stateful`

| Lint code | Check |
| --- | --- |
| `stateful_immutable` | All fields are `final`/`const`, and a `const` constructor exists |
| `stateful_has_mutable_state_stream` | Declares at least one `MutableStateStream` field |
| `stateful_closes_mutable_state_stream` | Calls `MutableStateStream.close()` somewhere in the class |
| `stateful_mutable_state_stream_freezed` | `MutableStateStream<T>` requires `T` to be a Freezed-annotated class |
| `stateful_methods_use_delegate` | Instance methods must call `@delegate.execute` (`close`/`_close` excepted) |
