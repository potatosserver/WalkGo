import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/advanced_settings_page.dart';
import 'package:walkgo/constants.dart';
import 'package:walkgo/health_service.dart';
import 'package:walkgo/log_service.dart';
import 'package:walkgo/settings_page.dart';
import 'l10n/app_localizations.dart';
import 'utils/step_calculator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LogService _logService = LogService();
  final HealthService _healthService = HealthService();
  bool _isAutoRunning = false;
  String _statusLog = "";
  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _intervalController = TextEditingController();
  Timer? _optimisticUiTimer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _setupServiceListeners();
    _startService();
  }

  Future<void> _startService() async {
    final service = FlutterBackgroundService();
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(prefPermissionsGranted) ?? false) {
      service.startService();
    }
  }

  void _setupServiceListeners() {
    final service = FlutterBackgroundService();
    service.on('update_ui').listen((event) {
      if (mounted && event != null) {
        setState(() {
          _statusLog = event['status_log'] ?? '';
          _isAutoRunning = event['is_running'] ?? false;
        });
      }
    });
  }

  @override
  void dispose() {
    _optimisticUiTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateStatusLogText();
  }

  Future<void> _updateStatusLogText() async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    final prefs = await SharedPreferences.getInstance();
    final isRunning = prefs.getBool(prefIsAuto) ?? false;
    String statusText;
    if (isRunning) {
      final nextRunTimestamp = prefs.getInt(prefNextRunTime);
      if (nextRunTimestamp != null) {
        final nextRun = DateTime.fromMillisecondsSinceEpoch(nextRunTimestamp);
        final formattedTime = DateFormat('HH:mm').format(nextRun);
        statusText = l10n.next_run_at(formattedTime);
      } else {
        statusText = l10n.status_running;
      }
    } else {
      statusText = l10n.status_ready_to_start;
    }
    if (mounted) {
      setState(() {
        _statusLog = statusText;
      });
    }
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _stepsController.text = (prefs.getInt(prefBaseSteps) ?? 500).toString();
      _intervalController.text = (prefs.getInt(prefInterval) ?? 1).toString();
    });
    _updateStatusLogText();
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        prefBaseSteps, int.tryParse(_stepsController.text) ?? 500);
    await prefs.setInt(
        prefInterval, int.tryParse(_intervalController.text) ?? 1);
    FlutterBackgroundService().invoke('update'); // Notify service of changes
  }

  void _updateStatus(String message, {bool isError = false}) {
    if (!mounted) return;
    Fluttertoast.showToast(
        msg: message,
        toastLength: isError ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
  }

  Future<void> _manualAdd() async {
    final l10n = AppLocalizations.of(context)!;
    await _saveSettings();
    final prefs = await SharedPreferences.getInstance();

    final baseSteps = int.tryParse(_stepsController.text) ?? 0;
    if (baseSteps <= 0) {
      _updateStatus(l10n.steps_gt_zero, isError: true);
      return;
    }

    final stepDetails = await calculateFinalSteps(prefs);
    final totalStepsToWrite = stepDetails['totalStepsToWrite']!;
    final originalSteps = stepDetails['originalSteps']!;
    final stepsAdded = stepDetails['stepsAdded']!;

    try {
      final success = await _healthService.writeSteps(totalStepsToWrite);
      if (success) {
        await _logService.addLog({
          'type': 'manual',
          'originalSteps': originalSteps,
          'stepsAdded': stepsAdded,
          'totalStepsWritten': totalStepsToWrite,
        });
        _updateStatus(l10n.manual_write_success(totalStepsToWrite));
      } else {
        _updateStatus(l10n.write_fail_check_log, isError: true);
      }
    } catch (e) {
      _updateStatus(l10n.write_error(e.toString()), isError: true);
    }
  }

  Future<void> _toggleAutoMode(bool enable) async {
    final l10n = AppLocalizations.of(context)!;
    await _saveSettings();
    final prefs = await SharedPreferences.getInstance();
    final service = FlutterBackgroundService();

    setState(() {
      _isAutoRunning = enable;
      _updateStatusLogText();
    });

    _optimisticUiTimer?.cancel();
    _optimisticUiTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        SharedPreferences.getInstance().then((prefs) {
          final actualRunningState = prefs.getBool(prefIsAuto) ?? false;
          if (_isAutoRunning != actualRunningState) {
            setState(() => _isAutoRunning = actualRunningState);
            _updateStatusLogText();
            _updateStatus(
                enable ? l10n.start_service_fail : l10n.stop_service_fail,
                isError: true);
          }
        });
      }
    });

    await prefs.setBool(prefIsAuto, enable);
    if (enable) {
      await prefs.setInt(prefSessionTotalSteps, 0);
      service.invoke('start');
      _updateStatus(l10n.start_auto_steps);
    } else {
      service.invoke("stop");
      _updateStatus(l10n.stop_auto_steps);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLightMode = theme.brightness == Brightness.light;

    final systemUiOverlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isLightMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: theme.colorScheme.surface,
        systemNavigationBarIconBrightness:
            isLightMode ? Brightness.dark : Brightness.light);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(l10n.walkgo),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage())),
              tooltip: l10n.settings_tooltip,
            ),
          ],
          elevation: 0,
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildStatusCard(l10n, theme),
                const SizedBox(height: 16),
                _buildSettingsCard(l10n, theme),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.touch_app_outlined),
                  label: Text(l10n.manual_write_once),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: theme.colorScheme.onSecondaryContainer,
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      elevation: 1),
                  onPressed: _manualAdd,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: Icon(_isAutoRunning
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_outline),
                  label: Text(_isAutoRunning
                      ? l10n.stop_auto_steps
                      : l10n.start_auto_steps),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.white,
                    backgroundColor: _isAutoRunning
                        ? Colors.red.shade600
                        : Colors.green.shade600,
                    textStyle: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _toggleAutoMode(!_isAutoRunning),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(AppLocalizations l10n, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final bool isRunning = _isAutoRunning;
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(icon, size: 48, color: contentColor),
            const SizedBox(height: 12),
            Text(
              _statusLog,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: contentColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(AppLocalizations l10n, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.dividerColor)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.param_settings,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTextField(
                controller: _stepsController,
                label: l10n.base_steps,
                icon: Icons.filter_1),
            const SizedBox(height: 16),
            _buildTextField(
                controller: _intervalController,
                label: l10n.interval,
                icon: Icons.timer_outlined),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon:
                    const Icon(Icons.settings_applications_outlined, size: 16),
                label: Text(l10n.advanced_settings,
                    style: theme.textTheme.labelMedium),
                style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdvancedSettingsPage())),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      required IconData icon}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))),
        filled: true,
      ),
      onChanged: (_) => _saveSettings(),
    );
  }
}
