import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walkgo/l10n/app_localizations.dart';
import 'package:walkgo/services/update_service.dart';

enum UpdateState { idle, downloading, downloaded, failed }

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
  final UpdateService _updateService = UpdateService();
  UpdateState _state = UpdateState.idle;
  bool _showManualDownload = false;
  double? _progress;
  String? _status;
  String? _error;
  String? _apkPath;
  String? _architecture;

  @override
  void initState() {
    super.initState();
    _updateService.getArchitecture().then((arch) {
      if (mounted) {
        setState(() {
          _architecture = arch;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final version = widget.release.tagName;

    return PopScope(
      canPop: _state != UpdateState.downloading,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _updateService.deleteApk();
        }
      },
      child: AlertDialog(
        title: Text(_showManualDownload
            ? l10n.manual_download_title
            : l10n.update_available),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_state == UpdateState.failed)
                  Text(
                    _error!,
                    style: TextStyle(color: theme.colorScheme.error),
                  )
                else if (_state == UpdateState.downloading)
                  ...[
                  Text(_status ?? l10n.updating),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: _progress),
                ] else if (_state == UpdateState.downloaded) ...[
                  Text(l10n.update_available_desc(version)),
                  const SizedBox(height: 16),
                  Text(l10n.installing),
                ] else if (_showManualDownload) ...[
                  _buildManualDownloadUi(l10n),
                ] else ...[
                  Text(l10n.update_available_desc(version)),
                  const SizedBox(height: 16),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MarkdownBody(data: widget.release.body),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
        actions: _buildActions(context, l10n),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, AppLocalizations l10n) {
    switch (_state) {
      case UpdateState.idle:
        if (_showManualDownload) {
          return [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.copy_link), // "Done"
            ),
            ElevatedButton(
              onPressed: () async {
                final url = Uri.parse(widget.release.htmlUrl);
                try {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } catch (e) {
                  Fluttertoast.showToast(msg: 'Could not launch URL');
                }
              },
              child: Text(l10n.go_to_download),
            ),
          ];
        } else {
          return [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _showManualDownload = true;
                });
              },
              child: Text(l10n.manual_download),
            ),
            ElevatedButton(
              onPressed: _startDownload,
              child: Text(l10n.auto_update),
            ),
          ];
        }
      case UpdateState.downloading:
        return [];
      case UpdateState.downloaded:
        return [
          ElevatedButton(
            onPressed: _install,
            child: Text(l10n.installing),
          ),
        ];
      case UpdateState.failed:
        return [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateService.deleteApk();
            },
            child: Text(l10n.close),
          ),
          ElevatedButton(
            onPressed: () {
              if (_apkPath != null) {
                setState(() {
                  _state = UpdateState.downloaded;
                  _error = null;
                });
                _install();
              } else {
                setState(() {
                  _showManualDownload = false;
                });
                _startDownload();
              }
            },
            child: Text(l10n.retry),
          ),
        ];
    }
  }

  Widget _buildManualDownloadUi(AppLocalizations l10n) {
    ReleaseAsset? asset;
    if (_architecture != null) {
      try {
        asset = widget.release.assets.firstWhere(
          (a) => a.name.contains(_architecture!) && a.name.endsWith('.apk'),
        );
      } catch (e) {
        asset = null;
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_architecture == null)
          const Center(child: CircularProgressIndicator())
        else
          Text(asset == null
              ? l10n.apk_not_found_for_arch(_architecture!)
              : l10n.manual_download_prompt(asset.name)),
      ],
    );
  }

  Future<void> _startDownload() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _state = UpdateState.downloading;
      _error = null;
      _progress = null;
    });

    try {
      final arch = _architecture ?? (await _updateService.getArchitecture());
      if (arch == null) {
        throw Exception(l10n.invalid_architecture);
      }
      if (mounted) {
        setState(() {
          _architecture = arch;
        });
      }

      _apkPath = await _updateService.downloadApk(
        widget.release,
        arch,
        onProgress: (p) => setState(() => _progress = p),
        onStatus: (s) => setState(() {
          if (s == 'Downloading APK...') {
            _status = l10n.downloading_apk;
          } else if (s == 'Verifying integrity...') {
            _status = l10n.verifying_integrity;
          } else {
            _status = s;
          }
        }),
      );
      setState(() {
        _state = UpdateState.downloaded;
      });
      await _install();
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = UpdateState.failed;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _install() async {
    final l10n = AppLocalizations.of(context)!;
    if (_apkPath == null) return;
    try {
      await _updateService.installApk(_apkPath!);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = UpdateState.failed;
          _error = l10n.install_failed(e.toString());
        });
      }
    }
  }
}
