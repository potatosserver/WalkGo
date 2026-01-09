
import 'package:flutter/material.dart' hide RadioGroup;
import 'package:provider/provider.dart';
import 'package:walkgo/language_service.dart';
import 'package:walkgo/l10n/app_localizations.dart';
import 'package:group_radio_button/group_radio_button.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = context.watch<LanguageService>();
    final currentLocale = languageService.appLocale;

    final languages = [null, const Locale('en'), const Locale('zh')];
    final languageNames = [l10n.system_language, l10n.english, l10n.chinese];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language_settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RadioGroup<Locale?>.builder(
          groupValue: currentLocale,
          onChanged: (Locale? value) {
            languageService.changeLanguage(value);
          },
          items: languages,
          itemBuilder: (item) => RadioButtonBuilder(
            languageNames[languages.indexOf(item)],
          ),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
