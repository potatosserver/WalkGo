import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:walkgo/l10n/app_localizations.dart';
import 'package:walkgo/services/update_service.dart';

class ReleaseNotesDialog extends StatelessWidget {
  final ReleaseInfo release;

  const ReleaseNotesDialog({super.key, required this.release});

  static void show(BuildContext context, ReleaseInfo release) {
    showDialog(
      context: context,
      builder: (context) => ReleaseNotesDialog(release: release),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(l10n.release_notes),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 400,
          maxWidth: 500,
        ),
        child: Scrollbar(
          child: SingleChildScrollView(
            child: MarkdownBody(
              data: release.body,
              selectable: true,
              styleSheet: MarkdownStyleSheet.fromTheme(theme),
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
