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
          child: Dialog(
            // Use a standard rounded corner to match Material 3 AlertDialog
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.0)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Force children to fill width
              children: [
                // Title section
                if (title != null || titleWidget != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: titleWidget ??
                        Text(
                          title!,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                  ),
                // Content section
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: content,
                    ),
                  ),
                ),
                // Actions section
                if (actions != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions!,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
