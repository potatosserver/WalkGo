import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:walkgo/l10n/app_localizations.dart';
import 'package:walkgo/services/update_service.dart';
import 'package:walkgo/widgets/update_dialog.dart';

class UpdateFlowDialog {
  static Future<void> run(BuildContext context, {bool force = false}) async {
    final l10n = AppLocalizations.of(context)!;

    Fluttertoast.showToast(msg: l10n.checking_for_updates);

    try {
      final updateService = UpdateService();
      final release = await updateService.checkForUpdate();

      if (release != null && release is ReleaseInfo) {
        if (!context.mounted) return;
        UpdateDialog.show(context, release);
      } else {
        if (force) {
          final latestRelease = await updateService.getLatestGithubRelease();
          if (latestRelease != null) {
            if (!context.mounted) return;
            UpdateDialog.show(context, latestRelease);
          } else {
            if (!context.mounted) return;
            Fluttertoast.showToast(msg: l10n.update_check_failed);
          }
        } else {
          if (!context.mounted) return;
          Fluttertoast.showToast(msg: l10n.latest_version_installed);
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      Fluttertoast.showToast(msg: l10n.update_check_failed);
    }
  }
}
