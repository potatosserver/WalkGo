import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walkgo/l10n/app_localizations.dart';
import 'package:walkgo/services/update_service.dart';
import 'package:walkgo/widgets/update_dialog.dart';

class UpdateFlowDialog {
  static Future<void> run(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    bool isCancelled = false;

    // Show checking dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(l10n.checking_for_updates),
          content: const SizedBox(
            height: 50,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                isCancelled = true;
                Navigator.of(context).pop();
              },
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
    );

    final updateService = UpdateService();
    final release = await updateService.checkForUpdate();

    if (isCancelled) {
      return;
    }

    // Close checking dialog
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (release != null) {
      if (!context.mounted) return;
      _showUpdateOptionsDialog(context, release, l10n);
    } else {
      Fluttertoast.showToast(msg: l10n.latest_version_installed);
    }
  }

  static void _showUpdateOptionsDialog(
      BuildContext context, ReleaseInfo release, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.update_available),
        content: Text(l10n.update_available_desc(release.tagName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showManualDownloadDialog(context, release, l10n);
            },
            child: Text(l10n.manual_download),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              UpdateDialog.show(context, release);
            },
            child: Text(l10n.auto_update),
          ),
        ],
      ),
    );
  }

  static void _showManualDownloadDialog(
      BuildContext context, ReleaseInfo release, AppLocalizations l10n) async {
    String architecture = 'unknown';
    String fileName = 'app-release.apk'; // Default filename

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      architecture = androidInfo.supportedAbis.first;
      // Find the asset that matches the architecture
      final matchingAsset = release.assets.firstWhere(
        (asset) => asset['name'].contains(architecture),
        orElse: () => null,
      );
      if (matchingAsset != null) {
        fileName = matchingAsset['name'];
      }
    } catch (e) {
      // Could be not on android
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.manual_download_title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.manual_download_description(architecture)),
            const SizedBox(height: 8),
            Text(
              l10n.manual_download_filename(fileName),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: release.htmlUrl));
              Fluttertoast.showToast(msg: l10n.link_copied);
            },
            child: Text(l10n.copy_link),
          ),
          FilledButton(
            onPressed: () async {
              final url = Uri.parse(release.htmlUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                Fluttertoast.showToast(msg: 'Could not open URL');
              }
            },
            child: Text(l10n.go_to_download),
          ),
        ],
      ),
    );
  }
}
