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
    final service = FlutterBackgroundService();
    service.on('manual_write_complete').listen((event) {
      if (!mounted) return;
      final steps = event?['steps'] as int?;
      if (steps == null) return;

      final l10n = AppLocalizations.of(context)!;
      Fluttertoast.showToast(
        msg: l10n.manual_write_success_feedback(steps.toString()),
        toastLength: Toast.LENGTH_SHORT,
      );
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
                        viewModel.manualWriteSteps();
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
