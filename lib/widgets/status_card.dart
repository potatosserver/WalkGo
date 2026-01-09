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

    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: isRunning
            ? _buildRunningState(context, viewModel, l10n, theme, contentColor)
            : _buildStoppedState(context, viewModel, theme, contentColor),
      ),
    );
  }

  Widget _buildStoppedState(
      BuildContext context, HomePageViewModel viewModel, ThemeData theme, Color contentColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_outline, size: 32, color: contentColor),
        const SizedBox(height: 8),
        Text(
          viewModel.statusLog,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold, color: contentColor),
        ),
      ],
    );
  }

  Widget _buildRunningState(BuildContext context, HomePageViewModel viewModel,
      AppLocalizations l10n, ThemeData theme, Color contentColor) {
    return Column(
      children: [
        // Top section for next run time
        Text(
          l10n.next_run_title,
          style: theme.textTheme.titleSmall?.copyWith(color: contentColor, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          viewModel.nextRunTime ?? '--:--',
          style: theme.textTheme.headlineMedium?.copyWith(color: contentColor, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Bottom section with three columns
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildMetricColumn(
                title: l10n.steps_written_this_session,
                value: viewModel.sessionTotalSteps.toString(),
                theme: theme,
                contentColor: contentColor,
              ),
            ),
            Expanded(
              child: _buildMetricColumn(
                title: l10n.this_run,
                value: viewModel.lastStepsWritten.toString(),
                theme: theme,
                contentColor: contentColor,
              ),
            ),
            Expanded(
              child: _buildMetricColumn(
                title: l10n.auto_pause_remaining,
                value: viewModel.autoPauseEnabled ? viewModel.remainingSteps.toString() : '---',
                theme: theme,
                contentColor: contentColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricColumn(
      {required String title, required String value, required ThemeData theme, required Color contentColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 36.0, // Set a fixed height to accommodate up to two lines
          alignment: Alignment.center,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: contentColor, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(color: contentColor, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
