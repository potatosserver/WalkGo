import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkgo/theme_provider.dart';
import 'l10n/app_localizations.dart';

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final selectedTheme = themeProvider.themeMode;

    void onThemeChanged(ThemeMode? newThemeMode) {
      if (newThemeMode == null) return;
      themeProvider.setTheme(newThemeMode);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.theme),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.system_theme),
            leading: Radio<ThemeMode>(
              value: ThemeMode.system,
              groupValue: selectedTheme,
              onChanged: onThemeChanged,
            ),
            onTap: () => onThemeChanged(ThemeMode.system),
          ),
          ListTile(
            title: Text(l10n.light_theme),
            leading: Radio<ThemeMode>(
              value: ThemeMode.light,
              groupValue: selectedTheme,
              onChanged: onThemeChanged,
            ),
            onTap: () => onThemeChanged(ThemeMode.light),
          ),
          ListTile(
            title: Text(l10n.dark_theme),
            leading: Radio<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: selectedTheme,
              onChanged: onThemeChanged,
            ),
            onTap: () => onThemeChanged(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}
