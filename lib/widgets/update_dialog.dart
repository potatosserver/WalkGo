import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/update_service.dart';

class UpdateDialog extends StatefulWidget {
  final Map<String, dynamic> release;

  const UpdateDialog({super.key, required this.release});

  static void show(BuildContext context, Map<String, dynamic> release) {
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
    final version = widget.release['tag_name'];

    return AlertDialog(
      title: Text(l10n.update_available),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!downloading && error == null)
            Text(l10n.update_available_desc(version)),
          if (downloading) ...[
            Text(status ?? l10n.updating),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: progress),
          ],
          if (error != null)
            Text(l10n.update_failed(error!),
                style: const TextStyle(color: Colors.red)),
        ],
      ),
      actions: [
        if (!downloading)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
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
