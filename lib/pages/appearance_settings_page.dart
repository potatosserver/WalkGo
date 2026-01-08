import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkgo/theme_provider.dart';
import 'package:walkgo/l10n/app_localizations.dart';

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();
    final currentMode = themeProvider.themeMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.theme),
      ),
      body: ListView(
        children: <Widget>[
          RadioListTile<ThemeMode>(
            title: Text(l10n.system_theme),
            value: ThemeMode.system,
            groupValue: currentMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                themeProvider.setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.light_theme),
            value: ThemeMode.light,
            groupValue: currentMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                themeProvider.setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.dark_theme),
            value: ThemeMode.dark,
            groupValue: currentMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                themeProvider.setThemeMode(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
