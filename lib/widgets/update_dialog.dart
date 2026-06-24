import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walkgo/l10n/app_localizations.dart';
import 'package:walkgo/services/update_service.dart';
import 'package:walkgo/widgets/app_dialog.dart';

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

enum UpdateStep { details, downloading, readyToInstall, error, manualDownload }

class _UpdateDialogState extends State<UpdateDialog> {
  UpdateStep _step = UpdateStep.details;
  double? _progress;
  String? _statusText;
  String? _errorText;
  String? _apkPath;
  String? _architecture;

  final _updateService = UpdateService();

  @override
  void initState() {
    super.initState();
    _determineArchitecture();
  }

  Future<void> _determineArchitecture() async {
    final arch = await _updateService.getArchitecture();
    if (mounted) {
      setState(() {
        _architecture = arch;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Wrap the entire content in a consistent height container
    // to prevent the dialog from jumping in size during state transitions.
    return AppDialog(
      title: _getTitle(l10n),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          child: _buildContent(context, l10n),
        ),
      ),
      actions: _buildActions(context, l10n),
    );
  }

  String _getTitle(AppLocalizations l10n) {
    switch (_step) {
      case UpdateStep.manualDownload:
        return l10n.manual_download_title;
      case UpdateStep.details:
      default:
        return l10n.update_available;
    }
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

      case UpdateStep.manualDownload:
        final arch = _architecture;
        if (arch == null) {
          return Text(l10n.invalid_architecture);
        }
        final apkName = 'app-$arch-release.apk';
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.manual_download_prompt),
            const SizedBox(height: 10),
            SelectableText(
              apkName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        );

      case UpdateStep.details:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.update_available_desc(widget.release.tagName)),
            const SizedBox(height: 16),
            Markdown(
              data: widget.release.body,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
          ],
        );
    }
  }

  List<Widget> _buildActions(BuildContext context, AppLocalizations l10n) {
    if (_step == UpdateStep.downloading) {
      return [];
    }

    switch (_step) {
      case UpdateStep.error:
        return [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(onPressed: _startDownload, child: Text(l10n.retry)),
        ];

      case UpdateStep.readyToInstall:
        return [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(onPressed: _installUpdate, child: Text(l10n.install)),
        ];

      case UpdateStep.manualDownload:
        return [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(l10n.complete),
          ),
          ElevatedButton(
            onPressed: () => launchUrl(
              Uri.parse(widget.release.htmlUrl),
              mode: LaunchMode.externalApplication,
            ),
            child: Text(l10n.go_to_download),
          ),
        ];

      case UpdateStep.details:
      default:
        return [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _step = UpdateStep.manualDownload;
              });
            },
            child: Text(l10n.manual_download),
          ),
          ElevatedButton(onPressed: _startDownload, child: Text(l10n.download)),
        ];
    }
  }

  Future<void> _startDownload() async {
    final l10n = AppLocalizations.of(context)!;
    if (_architecture == null) {
      setState(() {
        _step = UpdateStep.error;
        _errorText = l10n.invalid_architecture;
      });
      return;
    }
  }

  Future<void> _installUpdate() async {
    if (_apkPath == null) {
      _startDownload();
    }
    await _updateService.installFromPath(_apkPath!);
  }
}
