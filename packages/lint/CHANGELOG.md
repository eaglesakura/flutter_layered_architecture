## 0.1.0

- Initial release.
- Analyzer plugin (`analysis_server_plugin`) for Flutter Layered Architecture conventions.
- Architecture layer rules:
  - `architecture_layer_dependency`
  - `architecture_implementation_dependency`
- File layout / public API rules:
  - `one_public_type_per_file`
  - `public_type_file_name`
  - `unexported_public_must_be_internal`
- Annotation-backed rules for `@usecase`, `@delegate`, `@stateful`, `@viewModel`, and `@state` / `@entity`.
- Optional `layered_architecture.yaml` configuration (layer `path_prefix`, ignore lists, file-name keywords).
