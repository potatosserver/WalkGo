import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkgo/language_service.dart';
import 'package:walkgo/l10n/app_localizations.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = context.watch<LanguageService>();
    final currentLocale = languageService.appLocale;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language_settings),
      ),
      body: ListView(
        children: <Widget>[
          RadioListTile<Locale?>(
            title: Text(l10n.system_language),
            value: null,
            groupValue: currentLocale,
            onChanged: (Locale? value) {
              languageService.changeLanguage(value);
            },
          ),
          RadioListTile<Locale?>(
            title: Text(l10n.english),
            value: const Locale('en'),
            groupValue: currentLocale,
            onChanged: (Locale? value) {
              languageService.changeLanguage(value);
            },
          ),
          RadioListTile<Locale?>(
            title: Text(l10n.chinese),
            value: const Locale('zh'),
            groupValue: currentLocale,
            onChanged: (Locale? value) {
              languageService.changeLanguage(value);
            },
          ),
        ],
      ),
    );
  }
}
