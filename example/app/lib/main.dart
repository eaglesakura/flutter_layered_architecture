import 'package:example_app/example_app.dart';
import 'package:example_app/example_dependency_injection.dart';
import 'package:foundation_dependency_injection/foundation_dependency_injection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final builder = DependencyBuilder();
  const ExampleDependencyInjection().bind(builder);

  runApp(
    UncontrolledProviderScope(
      container: builder.build(),
      child: const ExampleApp(),
    ),
  );
}
