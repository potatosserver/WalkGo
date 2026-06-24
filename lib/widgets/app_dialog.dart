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

    // Responsive width logic:
    // Mobile (< 600dp): 90% of screen width
    // Tablet/Web (>= 600dp): 50% of screen width, capped at 600dp
    final double dialogWidth = screenWidth < 600
        ? screenWidth * 0.9
        : (screenWidth * 0.5).clamp(300.0, 600.0);

    return SizedBox(
      width: dialogWidth,
      child: AlertDialog(
        title: titleWidget ?? (title != null ? Text(title!) : null),
        content: content,
        actions: actions,
      ),
    );
  }
}
