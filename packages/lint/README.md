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

## Rules

### `@usecase`

| Lint code | Check |
| --- | --- |
| `usecase_single_method` | Declares exactly one instance method |
| `usecase_method_signature` | That method has parameters and a non-void return type |
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
