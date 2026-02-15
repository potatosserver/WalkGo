import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:walkgo/l10n/app_localizations.dart';
import 'package:walkgo/services/update_service.dart';

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

enum UpdateStep {
  details, // Show release notes and download button
  downloading, // Show progress bar
  readyToInstall, // Show install button (and retry install)
  error, // Show error message and retry download button
}

class _UpdateDialogState extends State<UpdateDialog> {
  UpdateStep _step = UpdateStep.details;
  double? _progress;
  String? _statusText;
  String? _errorText;
  String? _apkPath;

  final _updateService = UpdateService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.update_available),
      content: _buildContent(context, l10n),
      actions: _buildActions(context, l10n),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    switch (_step) {
      case UpdateStep.error:
        return Text(
          l10n.update_failed(_errorText ?? l10n.unknown_error),
          style: TextStyle(color: theme.colorScheme.error),
        );

      case UpdateStep.downloading:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_statusText ?? l10n.updating),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _progress),
          ],
        );

      case UpdateStep.readyToInstall:
        return Text(l10n.update_ready_to_install);

      case UpdateStep.details:
        return SizedBox(
          width: 500, // Give it a reasonable width for readability
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 300, // Max height, but can be shorter
            ),
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.update_available_desc(widget.release.tagName)),
                    const SizedBox(height: 16),
                    Markdown(
                      data: widget.release.body,
                      shrinkWrap: true, // Important for fitting content
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    }
  }

  List<Widget> _buildActions(BuildContext context, AppLocalizations l10n) {
    if (_step == UpdateStep.downloading) {
      return []; // No actions while downloading
    }

    switch (_step) {
      case UpdateStep.error:
        return [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: _startDownload,
            child: Text(l10n.retry),
          ),
        ];
      case UpdateStep.readyToInstall:
        return [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: _installUpdate,
            child: Text(l10n.install),
          ),
        ];
      case UpdateStep.details:
      default:
        return [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: _startDownload,
            child: Text(l10n.download),
          ),
        ];
    }
  }

  Future<void> _startDownload() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _step = UpdateStep.downloading;
      _errorText = null;
      _progress = null;
    });

    final arch = await _updateService.getArchitecture();
    if (arch == null) {
      if (!mounted) return;
      setState(() {
        _step = UpdateStep.error;
        _errorText = l10n.invalid_architecture;
      });
      return;
    }

    final String? downloadedPath = await _updateService.downloadUpdate(
      widget.release,
      arch,
      onProgress: (p) {
        if (!mounted) return;
        setState(() => _progress = p);
      },
      onStatus: (s) {
        if (!mounted) return;
        setState(() => _statusText = s);
      },
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _step = UpdateStep.error;
          _errorText = e;
        });
      },
    );

    if (downloadedPath != null && mounted) {
      setState(() {
        _step = UpdateStep.readyToInstall;
        _apkPath = downloadedPath;
      });
    }
  }

  Future<void> _installUpdate() async {
    if (_apkPath == null) {
      _startDownload();
      return;
    }
    await _updateService.installFromPath(_apkPath!);
  }
}
