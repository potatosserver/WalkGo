import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkgo/theme_provider.dart';
import 'l10n/app_localizations.dart';

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.theme),
      ),
      body: ListView(
        children: [
          _buildThemeOption(context, l10n.system_theme, ThemeMode.system, themeProvider),
          _buildThemeOption(context, l10n.light_theme, ThemeMode.light, themeProvider),
          _buildThemeOption(context, l10n.dark_theme, ThemeMode.dark, themeProvider),
        ],
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, String title, ThemeMode mode, ThemeProvider provider) {
    final bool isSelected = provider.themeMode == mode;
    return ListTile(
      title: Text(title),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: () => provider.setThemeMode(mode),
    );
  }
}
