import 'package:flutter/material.dart';

import 'di/app_dependencies.dart';
import 'presentation/app_flow.dart';

class RegattaApp extends StatelessWidget {
  const RegattaApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VKR Regatta',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: AppFlow(dependencies: dependencies),
    );
  }
}
