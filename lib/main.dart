import 'package:flutter/material.dart';
import 'package:projeto_final_m02/app.dart';
import 'package:projeto_final_m02/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const App());
}
