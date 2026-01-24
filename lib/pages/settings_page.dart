import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/log_service.dart';
import '../l10n/app_localizations.dart';

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
                onTap: () => context.push('/settings/appearance'),
              ),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(l10n.language_settings),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/settings/language'),
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
                onTap: () => context.push('/settings/logs'),
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
                onTap: () => context.push('/welcome'),
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
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.about_walkgo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.about_walkgo_content),
            const SizedBox(height: 20),
            Text(l10n.developer_label),
            const SizedBox(height: 8),
            Text(l10n.version_label("1.0.1"), style: theme.textTheme.bodySmall),
            const Divider(height: 32),
            InkWell(
              onTap: () async {
                final url =
                    Uri.parse('https://github.com/potatosserver/WalkGo');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  Fluttertoast.showToast(msg: 'Could not launch GitHub');
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.code, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.github_source_code,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, AppLocalizations l10n) {
    final router = GoRouter.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        final logService =
            Provider.of<LogService>(dialogContext, listen: false);
        final navigator = Navigator.of(dialogContext);
        return AlertDialog(
          title: Text(l10n.clear_data_confirm_title),
          content: Text(l10n.clear_data_confirm_content),
          actions: [
            TextButton(
                onPressed: () => navigator.pop(), child: Text(l10n.cancel)),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                // Stop the service before clearing data
                FlutterBackgroundService().invoke("stopService");
                await prefs.clear();
                await logService.clearLogs();
                Fluttertoast.showToast(msg: l10n.data_cleared_success);
                navigator.pop();
                router.go('/');
              },
              child: Text(l10n.confirm,
                  style: TextStyle(
                      color: Theme.of(dialogContext).colorScheme.error)),
            ),
          ],
        );
      },
    );
  }
}
