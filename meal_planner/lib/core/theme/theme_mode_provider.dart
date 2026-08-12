import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'app.theme_mode';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  var _hasLocalChange = false;

  @override
  ThemeMode build() {
    Future.microtask(_restore);
    return ThemeMode.light;
  }

  Future<void> _restore() async {
    if (_hasLocalChange) return;

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    if (stored == 'dark') {
      state = ThemeMode.dark;
    } else if (stored == 'light') {
      state = ThemeMode.light;
    }
  }

  bool get isDarkMode => state == ThemeMode.dark;

  Future<void> setDarkMode(bool enabled) async {
    _hasLocalChange = true;
    state = enabled ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, enabled ? 'dark' : 'light');
  }
}
