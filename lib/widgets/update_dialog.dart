import 'package:flutter/material.dart';
import 'package:walkgo/l10n/app_localizations.dart';
import 'package:walkgo/services/update_service.dart';
import 'package:walkgo/widgets/release_notes_dialog.dart';

class UpdateDialog extends StatefulWidget {
  final ReleaseInfo release;

  const UpdateDialog({super.key, required this.release});

  static void show(BuildContext context, ReleaseInfo release) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateDialog(release: release),
    );
  }

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  double? progress;
  String? status;
  String? error;
  bool downloading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final version = widget.release.tagName;

    return AlertDialog(
      title: Text(l10n.update_available),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (error != null)
              Text(
                l10n.update_failed(error!),
                style: TextStyle(color: theme.colorScheme.error),
              )
            else if (downloading)
              ...
            [
              Text(status ?? l10n.updating),
              const SizedBox(height: 16),
              LinearProgressIndicator(value: progress),
            ]
            else
              Text(l10n.update_available_desc(version)),
          ],
        ),
      ),
      actions: [
        if (!downloading)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        if (!downloading && error == null)
          TextButton(
            onPressed: () {
              ReleaseNotesDialog.show(context, widget.release);
            },
            child: Text(l10n.release_notes),
          ),
        if (!downloading && error == null)
          ElevatedButton(
            onPressed: _startUpdate,
            child: Text(l10n.confirm),
          ),
        if (error != null)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
      ],
    );
  }

  Future<void> _startUpdate() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      downloading = true;
      error = null;
    });

    final updateService = UpdateService();
    final arch = await updateService.getArchitecture();
    if (arch == null) {
      if (!mounted) return;
      setState(() {
        downloading = false;
        error = l10n.invalid_architecture;
      });
      return;
    }

    await updateService.downloadAndInstall(
      widget.release,
      arch,
      onProgress: (p) => setState(() => progress = p),
      onStatus: (s) {
        setState(() {
          if (s == 'Downloading APK...') {
            status = l10n.downloading_apk;
          } else if (s == 'Verifying integrity...') {
            status = l10n.verifying_integrity;
          } else {
            status = s;
          }
        });
      },
      onError: (e) => setState(() {
        downloading = false;
        error = e;
      }),
    );
  }
}
