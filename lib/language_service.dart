import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/constants.dart';

class LanguageService with ChangeNotifier {
  Locale? _appLocale;

  Locale? get appLocale => _appLocale;

  LanguageService() {
    loadLanguage();
  }

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(prefLanguageCode);
    if (languageCode != null && languageCode.isNotEmpty) {
      _appLocale = Locale(languageCode);
    } else {
      _appLocale = PlatformDispatcher.instance.locale;
    }
    notifyListeners();
  }

  Future<void> changeLanguage(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(prefLanguageCode);
      _appLocale = null;
    } else {
      await prefs.setString(prefLanguageCode, locale.languageCode);
      _appLocale = locale;
    }
    notifyListeners();
  }
}
