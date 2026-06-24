import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../l10n/app_localizations.dart';
import '../services/log_service.dart';
import '../services/update_service.dart';
import '../widgets/release_notes_dialog.dart';
import '../widgets/update_flow_dialog.dart';
import '../widgets/app_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _version = '...';

  @override
  void initState() {
    super.initState();
    _initVersion();
  }

  Future<void> _initVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = packageInfo.version;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _version = 'Error';
        });
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    if (!mounted) return;
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
    );
  }

  void _checkForGooglePlayUpdate(AppLocalizations l10n) async {
    try {
      final updateInfo = await UpdateService().checkForUpdate();
      if (updateInfo is AppUpdateInfo &&
          updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await UpdateService().startGooglePlayUpdate(updateInfo);
      } else {
        _showToast(l10n.latest_version_installed);
      }
    } catch (e) {
      _showToast(l10n.update_check_failed, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isGooglePlay = updateChannel == 'google_play';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SafeArea(
        child: ListView(
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
                if (isGooglePlay)
                  ListTile(
                    leading: const FaIcon(FontAwesomeIcons.googlePlay),
                    title: Text(l10n.view_on_google_play),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () async {
                      final url = Uri.parse(
                        'https://play.google.com/store/apps/details?id=com.potatosserver.walkgo',
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.system_update_outlined),
                  title: Text(l10n.check_for_updates),
                  onTap: () => isGooglePlay
                      ? _checkForGooglePlayUpdate(l10n)
                      : UpdateFlowDialog.run(context),
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
                if (!isGooglePlay)
                  ListTile(
                    leading: const Icon(Icons.download_outlined),
                    title: Text(l10n.download_latest_version),
                    onTap: () => UpdateFlowDialog.run(context, force: true),
                  ),
                ListTile(
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    l10n.clear_data_button,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  subtitle: Text(
                    l10n.app_reset_desc,
                    style: TextStyle(
                      color: theme.colorScheme.error.withAlpha(204),
                    ),
                  ),
                  onTap: () => _showClearDataDialog(context, l10n),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
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
    final isGooglePlay = updateChannel == 'google_play';
    showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: l10n.about_walkgo,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.about_walkgo_content),
            const SizedBox(height: 24),
            _buildAboutRow(
              context,
              icon: const FaIcon(FontAwesomeIcons.github, size: 24),
              text: l10n.github_source_code,
              trailing: const Icon(Icons.open_in_new, size: 20),
              onTap: () async {
                final url = Uri.parse(
                  'https://github.com/potatosserver/WalkGo',
                );
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),
            const SizedBox(height: 12),
            _buildAboutRow(
              context,
              icon: const Icon(Icons.badge_outlined, size: 24),
              text: l10n.developer_label,
            ),
            const SizedBox(height: 12),
            _buildAboutRow(
              context,
              icon: const Icon(Icons.info_outline, size: 24),
              text: l10n.version_label(_version),
            ),
            if (!isGooglePlay) ...[
              const Divider(height: 32),
              _buildAboutRow(
                context,
                icon: const Icon(Icons.article_outlined, size: 24),
                text: l10n.view_release_notes,
                onTap: () => _showReleaseNotes(context, l10n),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutRow(
    BuildContext context, {
    required Widget icon,
    required String text,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            IconTheme(
              data: IconThemeData(
                size: 24,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              child: icon,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              IconTheme(
                data: IconThemeData(color: theme.colorScheme.onSurfaceVariant),
                child: trailing,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showReleaseNotes(BuildContext context, AppLocalizations l10n) async {
    final updateService = UpdateService();

    try {
      final release = await updateService.getLatestGithubRelease();

      if (release != null) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (context) => ReleaseNotesDialog(release: release),
        );
      } else {
        _showToast(l10n.update_failed('Could not fetch release notes'),
            isError: true);
      }
    } catch (e) {
      _showToast(l10n.update_check_failed, isError: true);
    }
  }

  void _showClearDataDialog(BuildContext context, AppLocalizations l10n) {
    final router = GoRouter.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        final logService = Provider.of<LogService>(
          dialogContext,
          listen: false,
        );
        final navigator = Navigator.of(dialogContext);
        return AppDialog(
          title: l10n.clear_data_confirm_title,
          content: Text(l10n.clear_data_confirm_content),
          actions: [
            TextButton(
              onPressed: () => navigator.pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                await logService.clearLogs();
                if (context.mounted) {
                  navigator.pop(); // Close the confirmation dialog
                  _showToast(l10n.data_cleared_success);
                  router.go('/');
                }
              },
              child: Text(
                l10n.confirm,
                style: TextStyle(
                  color: Theme.of(dialogContext).colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
