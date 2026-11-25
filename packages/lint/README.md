# flutter_layered_architecture_lint

Custom lint rules for Flutter Layered Architecture conventions.

Add this package as a dependency, then enable the plugin with top-level
`plugins:` in `analysis_options.yaml` (workspace example):

```yaml
plugins:
  flutter_layered_architecture_lint:
    path: packages/lint
```

Pair with `flutter_layered_architecture_annotations`.

Architecture violations (`@usecase` / `@delegate` / `@stateful` / `@viewModel`,
`architecture_layer_dependency`, and `architecture_implementation_dependency`)
are reported as **WARNING**.

## Rules

### Architecture layer

| Lint code | Check |
| --- | --- |
| `architecture_layer_dependency` | Warns when a package under `layered_architecture.yaml` depends on a higher layer (pubspec direct deps only) |
| `architecture_implementation_dependency` | Warns when a non-`@injection` or cross-layer package depends on `@implementation` barrels (pubspec direct deps only) |

Uses the nearest `layered_architecture.yaml` found upward from the package root.
Missing or invalid definitions, overlapping `path_prefix` values, and
`dep.level > self.level` (when both sides have `level`) are warnings. Packages
outside every `path_prefix` (e.g. this lint package) are skipped. Unused layer
entries with no packages are allowed. Import-only deps are covered by
`depend_on_referenced_packages`, not this rule.

Helper unit test:

```bash
cd packages/lint && dart run test/architecture_layer_checkers_test.dart
```

### File layout

| Lint code | Check |
| --- | --- |
| `one_public_type_per_file` | At most one public named type (`class` / `enum` / `mixin` / named `extension` / `extension type`) per file |
| `public_type_file_name` | When exactly one public type exists, the file name must be its `lower_snake_case` form |
| `unexported_public_must_be_internal` | Public top-level symbols not exported from a `lib/` barrel (`library;`) must be `@internal` or private |

Optional keywords in the nearest `layered_architecture.yaml`:

```yaml
rules:
  public_type_file_name:
    keywords:
      UseCase: usecase
      ViewModel: viewmodel
```

With `UseCase: usecase`, type `AddTodoUseCase` expects `add_todo_usecase.dart`
(without keywords it would be `add_todo_use_case.dart`). Keywords are applied in
YAML declaration order (earlier keys win on overlapping segments). Missing or
empty `rules` / `keywords` keeps the default PascalCase→snake conversion.
Matching is case-sensitive (`UseCase` does not match type segment `Usecase`).

Skipped for `part of` files and paths under `test/`. Private (`_`-prefixed) types and `typedef`s are ignored by the one-type / file-name rules. Zero public types is allowed.

`unexported_public_must_be_internal` covers all public top-level symbols (`class` / `enum` / `mixin` / named `extension` / `extension type` / function / variable / `typedef`). Barrels are `lib/*.dart` files that declare `library;`. Packages with no such barrel are skipped.

Helper unit tests (assert runner; `package:test` conflicts with this workspace's `analyzer`/`flutter_test` pins):

```bash
cd packages/lint && dart run test/file_layout_checkers_test.dart
cd packages/lint && dart run test/public_api_checkers_test.dart
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
| `stateful_methods_use_delegate` | Instance/extension methods must call `@delegate.execute` (`close`/`_close` excepted) |

`@viewModel` also inherits these `@stateful` checks.

### `@viewModel`

| Lint code | Check |
| --- | --- |
| `viewmodel_internal` | Also annotated with `@internal` |
| `viewmodel_has_entity_getter` | Declares `StateStream<T> get entity` |
| `viewmodel_entity_freezed` | `entity` type argument `T` must be a Freezed-annotated class |
| `viewmodel_entity_differs_from_state` | `entity` model type must differ from the `MutableStateStream` state model |
| `viewmodel_on_method_names` | Instance/extension methods are named `on...` (`close`/`_close` excepted) |
