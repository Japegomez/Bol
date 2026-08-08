import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _seedColor = Color(0xFF4CAF50);

  // Computed once and cached: ColorScheme.fromSeed() runs Material 3's tonal
  // palette generation, which is expensive enough to notice as UI lag if
  // recomputed on every MaterialApp rebuild (e.g. toggling dark mode).
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
    ),
    scrollbarTheme: const ScrollbarThemeData(
      thumbVisibility: WidgetStatePropertyAll(true),
      trackVisibility: WidgetStatePropertyAll(true),
      thickness: WidgetStatePropertyAll(8),
      radius: Radius.circular(8),
      interactive: true,
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
    ),
    scrollbarTheme: const ScrollbarThemeData(
      thumbVisibility: WidgetStatePropertyAll(true),
      trackVisibility: WidgetStatePropertyAll(true),
      thickness: WidgetStatePropertyAll(8),
      radius: Radius.circular(8),
      interactive: true,
    ),
  );
}
