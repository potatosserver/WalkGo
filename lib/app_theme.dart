import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/constants.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;

  ThemeProvider() {
    _loadPreferences();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString(prefTheme) ?? 'system';
    final langCode = prefs.getString(prefLanguageCode);
    final countryCode = prefs.getString(prefCountryCode);

    switch (theme) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }

    if (langCode != null) {
      _locale = Locale(langCode, countryCode);
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    String themeStr;
    switch (mode) {
      case ThemeMode.light:
        themeStr = 'light';
        break;
      case ThemeMode.dark:
        themeStr = 'dark';
        break;
      case ThemeMode.system:
        themeStr = 'system';
        break;
    }
    await prefs.setString(prefTheme, themeStr);
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(prefLanguageCode);
      await prefs.remove(prefCountryCode);
    } else {
      await prefs.setString(prefLanguageCode, locale.languageCode);
      if (locale.countryCode != null) {
        await prefs.setString(prefCountryCode, locale.countryCode!);
      } else {
        await prefs.remove(prefCountryCode);
      }
    }
    notifyListeners();
  }
}
