import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walkgo/l10n/app_localizations.dart';
import 'package:walkgo/services/update_service.dart';
import 'package:walkgo/widgets/app_dialog.dart';

class ReleaseNotesDialog extends StatelessWidget {
  final ReleaseInfo release;

  const ReleaseNotesDialog({super.key, required this.release});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppDialog(
      title: l10n.release_notes,
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Scrollbar(
          child: SingleChildScrollView(
            child: SizedBox(
              width: double
                  .infinity, // FORCE the markdown to fill the dialog width
              child: Markdown(
                data: release.body,
                selectable: true,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onTapLink: (link, context, key) {
                  final Uri url = Uri.parse(link);
                  canLaunchUrl(url).then((canLaunch) {
                    if (canLaunch) {
                      launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  });
                },
              ),
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
