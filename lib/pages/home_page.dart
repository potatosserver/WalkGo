import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:walkgo/l10n/app_localizations.dart';
import 'package:walkgo/pages/settings_page.dart';
import 'package:walkgo/viewmodels/home_page_viewmodel.dart';
import 'package:walkgo/widgets/status_card.dart';
import 'package:walkgo/widgets/parameter_settings_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLightMode = theme.brightness == Brightness.light;

    final systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isLightMode ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: theme.colorScheme.surface,
      systemNavigationBarIconBrightness:
          isLightMode ? Brightness.dark : Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(l10n.walkgo),
          actions: [
            Consumer<HomePageViewModel>(
              builder: (context, viewModel, child) => IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                  viewModel.reloadSettings();
                },
                tooltip: l10n.settings_tooltip,
              ),
            ),
          ],
          elevation: 0,
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: Consumer<HomePageViewModel>(
            builder: (context, viewModel, child) {
              viewModel.setL10n(l10n);
              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  children: [
                    const StatusCard(),
                    const SizedBox(height: 16),
                    const ParameterSettingsCard(),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: Text(l10n.manual_steps_title),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: isLightMode
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                        foregroundColor:
                            isLightMode ? Colors.black : Colors.white,
                      ),
                      onPressed: () {
                        // The logic is now handled in the ViewModel,
                        // which will invoke the background service.
                        viewModel.manualWriteSteps();

                        // Show a toast to confirm that the action was triggered.
                        Fluttertoast.showToast(msg: l10n.manual_write_initiated);
                      },
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      icon: Icon(viewModel.isAutoRunning
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outline),
                      label: Text(viewModel.isAutoRunning
                          ? l10n.stop_auto_steps
                          : l10n.start_auto_steps),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: viewModel.isAutoRunning
                            ? Colors.red.shade600
                            : Colors.green.shade600,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => viewModel.toggleAutoMode(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
