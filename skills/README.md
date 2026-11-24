# Flutter Layered Architecture / Skills

`flutter_layered_architecture_lint` の各 linter rule に対応する SKILL 集。

## 配置

```text
skills/
├── apm.yml
└── .apm/skills/
    └── flutter-layered-architecture-linter-rule-{rule}/
        └── SKILL.md
```

ディレクトリ名・`SKILL.md` の `name` は診断コード（snake_case）の `_` を `-` に置換した形。

例: `usecase_single_method` → `flutter-layered-architecture-linter-rule-usecase-single-method`

## カテゴリ

| カテゴリ | rules |
| --- | --- |
| file_layout | `one_public_type_per_file`, `public_type_file_name`, `unexported_public_must_be_internal` |
| usecase | `usecase_single_method`, `usecase_method_signature`, `usecase_immutable` |
| delegate | `delegate_execute_method`, `delegate_immutable`, `delegate_internal`, `delegate_no_nested_delegate`, `delegate_no_usecase_instantiation` |
| stateful | `stateful_immutable`, `stateful_has_mutable_state_stream`, `stateful_closes_mutable_state_stream`, `stateful_mutable_state_stream_freezed`, `stateful_methods_use_delegate` |
| viewmodel | `viewmodel_internal`, `viewmodel_has_entity_getter`, `viewmodel_entity_freezed`, `viewmodel_entity_differs_from_state`, `viewmodel_on_method_names` |
