import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkgo/language_service.dart';
import 'package:walkgo/l10n/app_localizations.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language_settings),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: _buildSettingsCard(
          context,
          title: l10n.language_settings,
          children: [
            _buildLanguageOption(context, l10n.system_language, null),
            _buildLanguageOption(context, l10n.english, const Locale('en')),
            _buildLanguageOption(context, l10n.chinese, const Locale('zh')),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context,
      {required String title, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
      BuildContext context, String title, Locale? locale) {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    final bool isSelected = languageService.appLocale == locale;

    return ListTile(
      title: Text(title),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
          : const Icon(Icons.radio_button_unchecked),
      onTap: () {
        languageService.changeLanguage(locale);
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }
}
