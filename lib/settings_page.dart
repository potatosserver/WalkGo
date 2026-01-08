import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/appearance_settings_page.dart';
import 'package:walkgo/language_settings_page.dart';
import 'package:walkgo/log_service.dart';
import 'package:walkgo/logs_page.dart';
import 'l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        children: [
          _buildSettingsCard(
            context,
            title: l10n.param_settings,
            children: [
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: Text(l10n.theme),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AppearanceSettingsPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(l10n.language_settings),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LanguageSettingsPage()),
                  );
                },
              ),
            ],
          ),
          _buildSettingsCard(
            context,
            title: l10n.about,
            children: [
              ListTile(
                leading: const Icon(Icons.history_outlined),
                title: Text(l10n.write_logs),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LogsPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.about_walkgo),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showAboutDialog(context, l10n),
              ),
            ],
          ),
          _buildSettingsCard(
            context,
            title: l10n.app_reset,
            children: [
              ListTile(
                leading: const Icon(Icons.replay_outlined),
                title: Text(l10n.rerun_setup),
                onTap: () => _showRerunSetupDialog(context, l10n),
              ),
              ListTile(
                leading: Icon(Icons.delete_forever_outlined,
                    color: theme.colorScheme.error),
                title: Text(l10n.clear_data_button,
                    style: TextStyle(color: theme.colorScheme.error)),
                subtitle: Text(l10n.app_reset_desc,
                    style: TextStyle(
                        color: theme.colorScheme.error.withAlpha(204))),
                onTap: () => _showClearDataDialog(context, l10n),
              ),
            ],
          ),
        ],
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

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.about_walkgo),
        content: Text(l10n.about_walkgo_content),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
        ],
      ),
    );
  }

  void _showRerunSetupDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.rerun_setup_confirm_title),
        content: Text(l10n.rerun_setup_confirm_content),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              final prefs = await SharedPreferences.getInstance();
              // Stop the service before clearing data
              FlutterBackgroundService().invoke("stopService");
              await prefs.clear();
              await prefs.setBool('is_first_launch', true);
              Fluttertoast.showToast(msg: l10n.data_cleared_success);
              navigator.pop();
              navigator.popUntil((route) => route.isFirst);
              navigator.pushReplacementNamed('/');
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, AppLocalizations l10n) {
    final LogService logService = LogService();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.clear_data_confirm_title),
        content: Text(l10n.clear_data_confirm_content),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              final prefs = await SharedPreferences.getInstance();
              // Stop the service before clearing data
              FlutterBackgroundService().invoke("stopService");
              await prefs.clear();
              await logService.clearLogs();
              Fluttertoast.showToast(msg: l10n.data_cleared_success);
              navigator.pop();
              navigator.popUntil((route) => route.isFirst);
              navigator.pushReplacementNamed('/');
            },
            child: Text(l10n.confirm,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
