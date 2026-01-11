import 'package:flutter/material.dart' hide RadioGroup;
import 'package:provider/provider.dart';
import 'package:group_radio_button/group_radio_button.dart';
import '../l10n/app_localizations.dart';
import '../services/language_service.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = context.watch<LanguageService>();

    // Create a list of locales for the radio buttons. `null` represents the system default.
    final List<Locale?> locales = [null, ...AppLocalizations.supportedLocales];

    // Get the name for each locale.
    String getLocaleName(Locale? locale) {
      if (locale == null) {
        return l10n.system_language;
      }
      switch (locale.languageCode) {
        case 'en':
          return l10n.english;
        case 'zh':
          return l10n.chinese;
        default:
          return locale.languageCode;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language_settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RadioGroup<Locale?>.builder(
          groupValue: languageService.selectedLocale,
          onChanged: (Locale? value) {
            if (value == null) {
              // If the user selects "System Default", clear the saved preference.
              languageService.clearLocale();
            } else {
              // Otherwise, set the new locale preference.
              languageService.setLocale(value);
            }
          },
          items: locales,
          itemBuilder: (item) => RadioButtonBuilder(
            getLocaleName(item),
          ),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
