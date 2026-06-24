import 'dart:ui';

import 'package:flutter/material.dart' hide RadioGroup;
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';
import 'package:group_radio_button/group_radio_button.dart';
import '../l10n/app_localizations.dart';
import '../services/language_service.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  // Helper function to gather all required localized strings for the background service.
  Map<String, String> _getLocalizedStrings(AppLocalizations l10n) {
    return {
      'auto_pause_notification_title': l10n.auto_pause_notification_title,
      'auto_pause_notification_content_with_steps':
          l10n.auto_pause_notification_content_with_steps('{steps}'),
      'write_fail_check_log': l10n.write_fail_check_log,
      'automatic_write_success': l10n.automatic_write_success('{steps}'),
      'notification_next_run': l10n.notification_next_run('{time}'),
      'notification_service_running': l10n.notification_service_running,
      'background_service_start': l10n.background_service_start,
      'notification_service_stopped_title':
          l10n.notification_service_stopped_title,
      'notification_service_stopped_content':
          l10n.notification_service_stopped_content,
    };
  }

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
      appBar: AppBar(title: Text(l10n.language_settings)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: RadioGroup<Locale?>.builder(
            groupValue: languageService.selectedLocale,
            onChanged: (Locale? value) async {
              if (value == null) {
                languageService.clearLocale();
              } else {
                languageService.setLocale(value);
              }

              // Determine the locale that will actually be used.
              final newLocale = value ?? PlatformDispatcher.instance.locale;

              // Manually load the localizations for the new locale.
              final newL10n = await AppLocalizations.delegate.load(newLocale);

              // Prepare the map of strings to send to the background service.
              final localizedStrings = _getLocalizedStrings(newL10n);

              // Send the updated strings to the background service.
              FlutterBackgroundService().invoke(
                'update_localization',
                localizedStrings,
              );
            },
            items: locales,
            itemBuilder: (item) => RadioButtonBuilder(getLocaleName(item)),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
