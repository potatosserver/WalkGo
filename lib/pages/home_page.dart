import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:walkgo/l10n/app_localizations.dart';
import 'package:walkgo/viewmodels/home_page_viewmodel.dart';
import 'package:walkgo/widgets/status_card.dart';
import 'package:walkgo/widgets/parameter_settings_card.dart';
import 'package:walkgo/widgets/update_flow_dialog.dart';
import 'package:walkgo/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Trigger app activity reporting when entering home page
    reportAppActive();
    
    final service = FlutterBackgroundService();
    service.on('manual_write_complete').listen((event) {
      if (!mounted) return;
      final steps = event?['steps'] as int?;
      if (steps == null) return;

      final l10n = AppLocalizations.of(context)!;
      Fluttertoast.showToast(
        msg: l10n.manual_write_success_feedback(steps.toString()),
      );
      // After manual writing, refresh the total steps of the day immediately
      Provider.of<HomePageViewModel>(
        context,
        listen: false,
      ).refreshTodaySteps();
    });

    // Use the new update flow
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateFlowDialog.run(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      final viewModel = Provider.of<HomePageViewModel>(context, listen: false);
      viewModel.notifyAppDetached();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLightMode = theme.brightness == Brightness.light;

    // Define the style for the system bars
    final systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isLightMode ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: theme.colorScheme.surface,
      systemNavigationBarIconBrightness:
          isLightMode ? Brightness.dark : Brightness.light,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.walkgo),
        // FIX: Apply systemOverlayStyle directly to AppBar to override default behavior
        systemOverlayStyle: systemUiOverlayStyle,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push('/settings');
            },
            tooltip: l10n.settings_tooltip,
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        top: false, // Allow content to extend behind the transparent AppBar
        child: Consumer<HomePageViewModel>(
          builder: (context, viewModel, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              viewModel.setL10n(l10n);
            });
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: ListView(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: MediaQuery.of(context).padding.top +
                      16, // Adjust top padding for status bar
                  bottom: 16,
                ),
                children: [
                  const StatusCard(),
                  const SizedBox(height: 16),
                  const ParameterSettingsCard(),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(l10n.manual_write_button_text),
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
                      viewModel.manualWriteSteps();
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: Icon(
                      viewModel.isAutoRunning
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outline,
                    ),
                    label: Text(
                      viewModel.isAutoRunning
                          ? l10n.stop_auto_mode
                          : l10n.start_auto_mode,
                    ),
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
                    onPressed: () => viewModel.toggleAutoMode(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
