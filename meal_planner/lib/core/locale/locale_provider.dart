import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/locale/supported_locales.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'app.locale';

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale?> {
  var _hasLocalChange = false;

  @override
  Locale? build() {
    Future.microtask(_restore);
    return null;
  }

  Future<void> _restore() async {
    if (_hasLocalChange) return;

    final prefs = await SharedPreferences.getInstance();
    if (_hasLocalChange) return;

    final stored = prefs.getString(_storageKey);
    if (stored == null || stored.isEmpty) return;

    final locale = localeFromLanguageCode(stored);
    if (locale != null) {
      state = locale;
    }
  }

  String get currentLanguageCode =>
      state?.languageCode ?? WidgetsBinding.instance.platformDispatcher.locale.languageCode;

  Future<void> setLocale(Locale? locale) async {
    _hasLocalChange = true;
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_storageKey);
    } else {
      await prefs.setString(_storageKey, locale.languageCode);
    }
  }

  Future<void> setLanguageCode(String languageCode) async {
    final locale = localeFromLanguageCode(languageCode);
    if (locale == null) return;
    await setLocale(locale);
  }
}
