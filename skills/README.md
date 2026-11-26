# Flutter Layered Architecture / Skills

`flutter_layered_architecture_lint` / `flutter_layered_architecture_annotations` 向け SKILL 集。

## 配置

```text
skills/
├── apm.yml
└── .apm/skills/
    ├── flutter-layered-architecture-annotations/
    │   ├── SKILL.md
    │   └── references/          # アノテーション別（拡張時もこの形式）
    └── flutter-layered-architecture-linter-rule-{rule}/
        └── SKILL.md
```

### Annotations

付与判断・必須併記・連動 lint の入口。

* `flutter-layered-architecture-annotations`

### Linter rules

ディレクトリ名・`SKILL.md` の `name` は診断コード（snake_case）の `_` を `-` に置換した形。

例: `usecase_single_method` → `flutter-layered-architecture-linter-rule-usecase-single-method`

## カテゴリ（linter rules）

| カテゴリ | rules |
| --- | --- |
| architecture | `architecture_layer_dependency`, `architecture_implementation_dependency` |
| file_layout | `one_public_type_per_file`, `public_type_file_name`, `unexported_public_must_be_internal` |
| usecase | `usecase_single_method`, `usecase_method_signature`, `usecase_immutable` |
| delegate | `delegate_execute_method`, `delegate_immutable`, `delegate_internal`, `delegate_no_nested_delegate`, `delegate_no_usecase_instantiation` |
| stateful | `stateful_immutable`, `stateful_has_mutable_state_stream`, `stateful_closes_mutable_state_stream`, `stateful_mutable_state_stream_state`, `stateful_methods_use_delegate` |
| viewmodel | `viewmodel_internal`, `viewmodel_has_entity_getter`, `viewmodel_entity_annotated`, `viewmodel_entity_differs_from_state`, `viewmodel_on_method_names` |
| state_entity | `state_entity_freezed`, `state_entity_internal`, `state_entity_exclusive`, `state_entity_required_parameters`, `state_entity_no_named_factory` |
