import 'package:flutter/material.dart';

class AppDialog extends StatelessWidget {
  final String? title;
  final Widget content;
  final List<Widget>? actions;
  final Widget? titleWidget;

  const AppDialog({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.titleWidget,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Strict width logic:
    // Mobile (< 600dp): Always 90% of screen width
    // Tablet/Web (>= 600dp): Always 50% of screen width, capped at 600dp
    final double dialogWidth = screenWidth < 600
        ? screenWidth * 0.9
        : (screenWidth * 0.5).clamp(300.0, 600.0);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: SizedBox(
          width: dialogWidth,
          child: AlertDialog(
            insetPadding: EdgeInsets.zero,
            title: titleWidget ?? (title != null ? Text(title!) : null),
            // FORCE the content to expand to the full width of the SizedBox
            // This prevents the dialog from shrinking when the content is narrow
            content: SizedBox(
              width: double.infinity,
              child: content,
            ),
            actions: actions,
            contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
          ),
        ),
      ),
    );
  }
}
