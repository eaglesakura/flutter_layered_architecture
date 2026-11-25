import 'package:data_injection/data_injection.dart';
import 'package:foundation_dependency_injection/foundation_dependency_injection.dart';
import 'package:usecase_injection/usecase_injection.dart';

/// Binds sample interface providers to implementations via layer injection packages.
final class ExampleDependencyInjection {
  const ExampleDependencyInjection();

  void bind(DependencyBuilder builder) {
    const DataInjectionBindings().bind(builder);
    const UsecaseInjectionBindings().bind(builder);
  }
}
