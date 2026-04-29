import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/di/app_dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = AppDependencies.bootstrap();
  runApp(RegattaApp(dependencies: dependencies));
}
