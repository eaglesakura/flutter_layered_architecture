import 'package:example_app/dependency_builder.dart';
import 'package:example_app/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('shows todo screen title', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: const DependencyBuilder().build(),
        child: const ExampleApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Layered TODO'), findsOneWidget);
    expect(find.text('No TODOs yet'), findsOneWidget);
  });
}
