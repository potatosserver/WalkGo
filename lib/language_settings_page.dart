import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkgo/language_service.dart';
import 'l10n/app_localizations.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language_settings),
      ),
      body: ListView(
        children: [
          _buildLanguageOption(
              context, l10n.english, const Locale('en'), languageService),
          _buildLanguageOption(context, l10n.traditional_chinese,
              const Locale('zh', 'TW'), languageService),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String title, Locale locale,
      LanguageService service) {
    final bool isSelected = service.appLocale == locale;
    return ListTile(
      title: Text(title),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: () => service.changeLanguage(locale),
    );
  }
}
