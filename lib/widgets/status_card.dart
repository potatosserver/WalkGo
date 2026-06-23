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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Section: Icon & Status (Fixed Layout)
            SizedBox(
              height: 80, // Fixed height for the entire top block
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isRunning) ...[
                    Icon(
                      Icons.check_circle_outline,
                      size: 36,
                      color: contentColor,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.status_ready_to_start,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: contentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else ...[
                    // When running, only show the "Next run" info to avoid redundancy
                    Text(
                      l10n.next_run_title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: contentColor.withAlpha(200),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      viewModel.nextRunTime ?? '--:--',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: contentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),
            // Fixed height container to ensure ABSOLUTELY zero layout shift
            SizedBox(
              height: 100, // Fixed height for the metrics area
              child: AnimatedCrossFade(
                firstChild: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: contentColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.today_steps_total(
                          viewModel.todayTotalSteps.toString(),
                        ),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: contentColor.withAlpha(200),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                secondChild: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Divider(color: contentColor.withAlpha(40), thickness: 1),
                    const SizedBox(height: 12),
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
                            value: viewModel.autoPauseEnabled
                                ? viewModel.remainingSteps.toString()
                                : '---',
                            theme: theme,
                            contentColor: contentColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                crossFadeState: isRunning
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn({
    required String title,
    required String value,
    required ThemeData theme,
    required Color contentColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 36.0, // Set a fixed height to accommodate up to two lines
          alignment: Alignment.center,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: contentColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: contentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
