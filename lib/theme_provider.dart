import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String prefTheme = "theme_mode";

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString =
        prefs.getString(prefTheme) ?? ThemeMode.system.toString();
    _themeMode = ThemeMode.values.firstWhere(
      (e) => e.toString() == themeString,
      orElse: () => ThemeMode.system,
    );
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    _themeMode = themeMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefTheme, themeMode.toString());
    notifyListeners();
  }
}
