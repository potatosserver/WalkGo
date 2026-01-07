import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';

class LanguageService {
  static late AppLocalizations _l10n;

  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode') ?? 'en';
    _l10n = await AppLocalizations.delegate.load(Locale(languageCode));
  }

  static AppLocalizations get l10n => _l10n;
}
