import 'package:flutter/material.dart' hide RadioGroup;
import 'package:provider/provider.dart';
import 'package:walkgo/theme_provider.dart';
import 'package:walkgo/l10n/app_localizations.dart';
import 'package:group_radio_button/group_radio_button.dart';

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});

  String _getThemeModeName(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.system_theme;
      case ThemeMode.light:
        return l10n.light_theme;
      case ThemeMode.dark:
        return l10n.dark_theme;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();
    final currentMode = themeProvider.themeMode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.theme)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RadioGroup<ThemeMode>.builder(
          groupValue: currentMode,
          onChanged: (ThemeMode? value) {
            if (value != null) {
              themeProvider.setThemeMode(value);
            }
          },
          items: ThemeMode.values,
          itemBuilder: (item) =>
              RadioButtonBuilder(_getThemeModeName(item, l10n)),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
