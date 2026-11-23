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
