# Flutter Layered Architecture Example

Web-only sample TODO app split into packages that mirror production layout.

## Layout

```text
example/
├── app/                              # example_app (Flutter Web)
├── domain/
│   └── todo/                         # domain_todo
├── data/
│   └── repository/
│       └── todo/                     # data_repository_todo
│           └── _impl/                # data_repository_todo_impl
├── usecase/
│   └── todo/                         # usecase_todo
│       └── _impl/                    # usecase_todo_impl
└── screen/
    └── feature/
        └── todo_list/                # screen_feature_todo_list
```

## Run (Web)

```bash
cd example/app
mise exec -- flutter pub get
mise exec -- flutter run -d chrome
```

## Build (Web)

```bash
cd example/app
mise exec -- flutter build web
```
