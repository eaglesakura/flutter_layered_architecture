import 'package:example_app/dependency_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:screen_feature_todo_list/screen_feature_todo_list.dart';

void main() {
  final overrides = const DependencyBuilder().build();
  runApp(
    ProviderScope(
      overrides: overrides,
      child: const ExampleApp(),
    ),
  );
}

/// Root widget for the Flutter Layered Architecture sample.
final class ExampleApp extends StatelessWidget {
  /// Creates an [ExampleApp].
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Layered Architecture Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const TodoListScreen(),
    );
  }
}
