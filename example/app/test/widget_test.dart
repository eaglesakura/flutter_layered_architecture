import 'package:example_app/example_app.dart';
import 'package:example_app/example_dependency_injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_dependency_injection/foundation_dependency_injection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('shows todo screen title', (tester) async {
    final builder = DependencyBuilder();
    const ExampleDependencyInjection().bind(builder);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: builder.build(),
        child: const ExampleApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Layered TODO'), findsOneWidget);
    expect(find.text('No TODOs yet'), findsOneWidget);
  });
}
