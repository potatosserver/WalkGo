import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import 'package:walkgo/l10n/app_localizations.dart';
import 'package:walkgo/services/update_service.dart';
import 'package:walkgo/widgets/app_dialog.dart';

class ReleaseNotesDialog extends StatelessWidget {
  final ReleaseInfo release;

  const ReleaseNotesDialog({super.key, required this.release});

  // Removed _ensureMarkdownLinks because flutter_html and markdown lib handle it natively
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
              width: double.infinity,
              child: Html(
                data: md.markdownToHtml(release.body),
                onLinkTap: (url, _, __) {
                  if (url == null) return;
                  final uri = Uri.parse(url);
                  canLaunchUrl(uri).then((canLaunch) {
                    if (canLaunch) {
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  });
                },
                style: {
                  "body": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    fontSize: FontSize(14.0),
                  ),
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
