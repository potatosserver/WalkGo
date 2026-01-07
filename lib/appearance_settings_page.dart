import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    final theme = Theme.of(context);
    final isLightMode = theme.brightness == Brightness.light;

    final systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isLightMode ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: theme.colorScheme.surface, // Changed from black
      systemNavigationBarIconBrightness:
          isLightMode ? Brightness.dark : Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(l10n.theme),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: ListView(
            children: [
              SizedBox(height: kToolbarHeight), // Add space for AppBar
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
        ),
      ),
    );
  }
}
