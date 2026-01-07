import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/appearance_settings_page.dart';
import 'package:walkgo/language_settings_page.dart';
import 'package:walkgo/log_service.dart';
import 'package:walkgo/logs_page.dart';
import 'l10n/app_localizations.dart';
import 'package:walkgo/main.dart';
import 'package:health/health.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _showAboutDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.about_walkgo),
        content: Text(l10n.about_walkgo_content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Future<void> _reviewSetup() async {
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
    }
  }

  Future<void> _clearAllData() async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clear_data_confirm_title),
        content: Text(l10n.clear_data_confirm_content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.confirm,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final service = FlutterBackgroundService();
      service.invoke("stopService");

      final health = Health();
      await health.revokePermissions();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      await prefs.setBool(prefIsFirstLaunch, true);
      await prefs.setBool(prefPermissionsGranted, false);

      await LogService().clearLogs();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.clear_data_success_toast)),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          title: Text(l10n.settings),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            children: [
              SizedBox(height: kToolbarHeight), // Add space for AppBar
              _buildNavigationCard(
                context,
                icon: Icons.language,
                title: l10n.language,
                page: const LanguageSettingsPage(),
              ),
              const SizedBox(height: 16),
              _buildNavigationCard(
                context,
                icon: Icons.palette_outlined,
                title: l10n.theme,
                page: const AppearanceSettingsPage(),
              ),
              const SizedBox(height: 16),
              _buildNavigationCard(
                context,
                icon: Icons.history,
                title: l10n.write_logs,
                page: const LogsPage(),
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                context,
                icon: Icons.shield_outlined,
                title: l10n.manage_permissions,
                onTap: openAppSettings,
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                context,
                icon: Icons.info_outline,
                title: l10n.about,
                onTap: _showAboutDialog,
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                context,
                icon: Icons.replay_outlined,
                title: l10n.rerun_setup,
                onTap: _reviewSetup,
                iconColor: Colors.orangeAccent,
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                context,
                icon: Icons.delete_forever,
                title: l10n.clear_data_button,
                onTap: _clearAllData,
                iconColor: Theme.of(context).colorScheme.error,
                textColor: Theme.of(context).colorScheme.error,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationCard(BuildContext context,
      {required IconData icon, required String title, required Widget page}) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap,
      Color? iconColor,
      Color? textColor}) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary),
        title: Text(title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor)),
        onTap: onTap,
      ),
    );
  }
}
