import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkgo/theme_provider.dart';
import 'package:walkgo/l10n/app_localizations.dart';

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.theme),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: _buildSettingsCard(
          context,
          title: l10n.theme,
          children: [
            _buildThemeOption(context, l10n.system_theme, ThemeMode.system),
            _buildThemeOption(context, l10n.light_theme, ThemeMode.light),
            _buildThemeOption(context, l10n.dark_theme, ThemeMode.dark),
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

  Widget _buildThemeOption(BuildContext context, String title, ThemeMode mode) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final bool isSelected = themeProvider.themeMode == mode;

    return ListTile(
      title: Text(title),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
          : const Icon(Icons.radio_button_unchecked),
      onTap: () {
        themeProvider.setThemeMode(mode);
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }
}
