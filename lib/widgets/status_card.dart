import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkgo/l10n/app_localizations.dart';
import 'package:walkgo/viewmodels/home_page_viewmodel.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomePageViewModel>(context);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isRunning = viewModel.isAutoRunning;
    final cardColor = isRunning
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final contentColor = isRunning
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;
    final icon = isRunning ? Icons.directions_walk : Icons.check_circle_outline;

    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: contentColor),
            const SizedBox(height: 8),
            Text(
              viewModel.statusLog,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold, color: contentColor),
            ),
            if (isRunning && (viewModel.remainingSteps > 0))
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.steps_written_this_session,
                            style: theme.textTheme.bodySmall),
                        Text('${viewModel.sessionTotalSteps}',
                            style: theme.textTheme.titleLarge),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(l10n.auto_pause_remaining,
                            style: theme.textTheme.bodySmall),
                        Text('${viewModel.remainingSteps}',
                            style: theme.textTheme.titleLarge),
                      ],
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
