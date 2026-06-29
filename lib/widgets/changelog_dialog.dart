
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:walkgo/l10n/app_localizations.dart';
import 'package:walkgo/widgets/app_dialog.dart';

class ChangelogDialog extends StatelessWidget {
  const ChangelogDialog({super.key});

  static const String _changelogUrl = 'https://raw.githubusercontent.com/potatosserver/WalkGo/main/CHANGELOG.md';

  String _ensureMarkdownLinks(String text) {
    final urlRegex = RegExp(
      r'(?<!\()https?://[^\s\n]+',
      caseSensitive: false,
    );
    return text.replaceAllMapped(urlRegex, (match) {
      final url = match.group(0)!;
      return '[$url]($url)';
    });
  }

  Future<String> _loadChangelog() async {
    try {
      final response = await http.get(Uri.parse(_changelogUrl));
      if (response.statusCode == 200) {
        String content = response.body;
        
        // Remove the main title (H1) and any intro text to avoid repetition with dialog title
        // We look for the first occurrence of '##' (the first version entry)
        final firstVersionIndex = content.indexOf('## ');
        if (firstVersionIndex != -1) {
          return content.substring(firstVersionIndex);
        }
        return content;
      } else {
        return 'Error loading changelog (Status: ${response.statusCode})';
      }
    } catch (e) {
      return 'Error loading changelog: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<String>(
      future: _loadChangelog(),
      builder: (context, snapshot) {
        String content = '';
        if (snapshot.connectionState == ConnectionState.done) {
          content = snapshot.data ?? 'No changelog available.';
        } else {
          content = 'Loading...';
        }

        return AppDialog(
          title: l10n.changelog,
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Scrollbar(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: Html(
                    data: md.markdownToHtml(_ensureMarkdownLinks(content)),
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
                      "hr": Style(
                        margin: Margins.zero,
                      ),
                      "h2": Style(
                        margin: Margins.zero,
                        fontSize: FontSize(18.0),
                        fontWeight: FontWeight.bold,
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
      },
    );
  }
}
