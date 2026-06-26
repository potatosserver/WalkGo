import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walkgo/l10n/app_localizations.dart';
import 'package:walkgo/services/update_service.dart';
import 'package:walkgo/widgets/app_dialog.dart';

class ReleaseNotesDialog extends StatelessWidget {
  final ReleaseInfo release;

  const ReleaseNotesDialog({super.key, required this.release});

  String _ensureMarkdownLinks(String text) {
    // 使用負向後瞻，確保網址前面不是 '('，避免重複包裹 Markdown 連結
    final urlRegex = RegExp(
      r'(?<!\()https?://[^\s\n]+',
      caseSensitive: false,
    );
    return text.replaceAllMapped(urlRegex, (match) {
      final url = match.group(0)!;
      return '[$url]($url)';
    });
  }

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
                data: _ensureMarkdownLinks(release.body),
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
