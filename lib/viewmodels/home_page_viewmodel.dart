import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/constants.dart';
import 'package:walkgo/l10n/app_localizations.dart';
import 'package:walkgo/services/log_service.dart';

class HomePageViewModel extends ChangeNotifier {
  final FlutterBackgroundService _service = FlutterBackgroundService();

  bool _isAutoRunning = false;
  String _statusLog = "";
  int _sessionTotalSteps = 0;
  int _lastStepsWritten = 0;
  int _remainingSteps = 0;
  String _baseSteps = "500";
  String _interval = "1";
  bool _autoPauseEnabled = false;
  String? _nextRunTime;

  bool get isAutoRunning => _isAutoRunning;
  String get statusLog => _statusLog;
  int get sessionTotalSteps => _sessionTotalSteps;
  int get lastStepsWritten => _lastStepsWritten;
  int get remainingSteps => _remainingSteps;
  String get baseSteps => _baseSteps;
  String get interval => _interval;
  bool get autoPauseEnabled => _autoPauseEnabled;
  String? get nextRunTime => _nextRunTime;

  AppLocalizations? _l10n;

  void setL10n(AppLocalizations l10n) {
    if (_l10n == null) {
      _l10n = l10n;

      // Fix for first launch: checks if we have a status, if not, set to ready.
      if (_statusLog.isEmpty) {
        _statusLog = _l10n!.status_ready_to_start;
        notifyListeners();
      }

      // When l10n is first set, we can finally get the status with proper localization.
      _service.invoke('get_status');
    }
  }

  HomePageViewModel() {
    // Attach LogService to background service listener.
    // This is safe here because ViewModel is always created in the UI isolate.
    LogService().attachToBackgroundService();
    _initialize();
  }

  Future<void> _initialize() async {
    _setupServiceListeners();
    await _loadNonStateSettings();

    // Request initial status from the service.
    // The service will respond with an 'update_ui' event.
    final isServiceRunning = await _service.isRunning();
    if (isServiceRunning) {
      _service.invoke('get_status');
    }
  }

  // This method is now specifically for a conditional shutdown.
  void notifyAppDetached() {
    _service.invoke("app_detached");
  }

  void _setupServiceListeners() {
    _service.on('update_ui').listen((event) async {
      if (event == null) return;

      _isAutoRunning = event['is_running'] as bool? ?? _isAutoRunning;
      _sessionTotalSteps =
          (event['session_total_steps'] as num?)?.toInt() ?? _sessionTotalSteps;
      _lastStepsWritten =
          (event['last_steps_written'] as num?)?.toInt() ?? _lastStepsWritten;
      _nextRunTime = event['next_run_time'] as String?;

      if (_l10n != null) {
        // Use the status log from the event, fallback to generalized terms only if missing
        final receivedStatus = event['status_log'] as String?;
        if (receivedStatus != null) {
          _statusLog = receivedStatus;
        } else {
          _statusLog = _isAutoRunning
              ? _l10n!.status_running
              : _l10n!.status_ready_to_start;
        }
      }

      await _updateRemainingSteps();
      notifyListeners();
    });

    _service.on('settings_updated').listen((event) {
      reloadSettings();
    });
  }

  Future<void> _loadNonStateSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    _baseSteps = (prefs.getInt(prefBaseSteps) ?? 500).toString();
    _interval = (prefs.getInt(prefInterval) ?? 1).toString();
    _autoPauseEnabled = prefs.getBool(prefAutoPauseEnabled) ?? false;

    // Only load session data from prefs if service is NOT running.
    // Otherwise, let the 'update_ui' event handle it.
    if (!(await _service.isRunning())) {
      _sessionTotalSteps = prefs.getInt(prefSessionTotalSteps) ?? 0;
      _lastStepsWritten = prefs.getInt(prefLastStepsWritten) ?? 0;

      if (_l10n != null) {
        _statusLog = _l10n!.status_ready_to_start;
      }
    }

    await _updateRemainingSteps();
    notifyListeners();
  }

  Future<void> _updateRemainingSteps() async {
    final prefs = await SharedPreferences.getInstance();
    final autoPauseSteps = prefs.getInt(prefAutoPauseThreshold) ?? 5000;
    _remainingSteps = autoPauseSteps - _sessionTotalSteps;
    if (_remainingSteps < 0) _remainingSteps = 0;
  }

  Future<void> reloadSettings() async {
    await _loadNonStateSettings();
  }

  Future<void> saveBaseSteps(String value) async {
    _baseSteps = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefBaseSteps, int.tryParse(value) ?? 500);
    updateSettingsInService();
    notifyListeners();
  }

  Future<void> saveInterval(String value) async {
    _interval = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefInterval, int.tryParse(value) ?? 1);
    updateSettingsInService();
    notifyListeners();
  }

  // Method to be called from other ViewModels to trigger a service settings refresh.
  void updateSettingsInService() {
    _service.invoke('update');
  }

  Map<String, String> _getLocalizedStrings() {
    if (_l10n == null) return {};
    return {
      'notification_service_running': _l10n!.notification_service_running,
      'notification_steps_written_title':
          _l10n!.notification_steps_written_title,
      'notification_steps_written':
          _l10n!.notification_steps_written('{steps}'),
      'notification_next_run': _l10n!.notification_next_run('{time}'),
      'automatic_write_success': _l10n!.automatic_write_success('{steps}'),
      'write_fail_check_log': _l10n!.write_fail_check_log,
      'notification_service_stopped_title':
          _l10n!.notification_service_stopped_title,
      'notification_service_stopped_content':
          _l10n!.notification_service_stopped_content,
      'background_service_start': _l10n!.background_service_start,
      'auto_pause_notification_title': _l10n!.auto_pause_notification_title,
      'auto_pause_notification_content_with_steps':
          _l10n!.auto_pause_notification_content_with_steps('{steps}'),
    };
  }

  Future<void> updateLocalization() async {
    if (_l10n != null) {
      _service.invoke('update_localization', _getLocalizedStrings());
    }
  }

  Future<void> toggleAutoMode() async {
    if (_l10n == null) return;

    final isCurrentlyRunning = await _service.isRunning();

    if (!isCurrentlyRunning) {
      await _service.startService();
      _service.invoke('start', _getLocalizedStrings());
      Fluttertoast.showToast(msg: _l10n!.auto_service_started);
    } else {
      _service.invoke("stop", _getLocalizedStrings());
      Fluttertoast.showToast(msg: _l10n!.auto_service_stopped);
    }
  }

  void manualWriteSteps() {
    if (_l10n == null) return;
    _service.invoke('write_now', {
      ..._getLocalizedStrings(),
      'source': 'manual',
    });
  }
}
