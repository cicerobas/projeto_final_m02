import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _seedColor = Color(0xFF673D8C);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
  );
}
