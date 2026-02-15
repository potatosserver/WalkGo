import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:walkgo/l10n/app_localizations.dart';
import 'package:walkgo/services/update_service.dart';

class ReleaseNotesDialog extends StatelessWidget {
  final ReleaseInfo release;

  const ReleaseNotesDialog({super.key, required this.release});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.release_notes),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 300, // Changed from 400 to 300
          maxWidth: 500,
        ),
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Markdown(
              data: release.body,
              selectable: true,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}
