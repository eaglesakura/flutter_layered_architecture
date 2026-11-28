import "dart:async";

import "package:testing_golden/testing_golden.dart";

/// Setup test.
Future<void> testExecutable(FutureOr<void> Function() testMain) =>
    goldenTestExecutable(testMain);
