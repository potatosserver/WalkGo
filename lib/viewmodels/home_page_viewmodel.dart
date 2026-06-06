import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/services/health_service.dart';
import 'package:walkgo/constants.dart';
import 'package:walkgo/l10n/app_localizations.dart';
import 'package:walkgo/services/log_service.dart';

class HomePageViewModel extends ChangeNotifier with WidgetsBindingObserver {
  final FlutterBackgroundService _service = FlutterBackgroundService();

  bool _isAutoRunning = false;
  // ... (previous fields remain the same)
  // [Internal State Fields Placeholder for brevity, no changes above this line in the real file]
  String _statusLog = "";
  int _sessionTotalSteps = 0;
  int _lastStepsWritten = 0;
  int _remainingSteps = 0;
  String _baseSteps = "500";
  String _interval = "1";
  bool _autoPauseEnabled = false;
  int _autoPauseThreshold = 5000;
  bool _offsetEnabled = true;
  int _offsetSteps = 50;
  int _todayTotalSteps = 0;
  String? _nextRunTime;

  // ... (getters remain the same)
  bool get isAutoRunning => _isAutoRunning;
  String get statusLog => _statusLog;
  int get sessionTotalSteps => _sessionTotalSteps;
  int get lastStepsWritten => _lastStepsWritten;
  int get remainingSteps => _remainingSteps;
  String get baseSteps => _baseSteps;
  String get interval => _interval;
  bool get autoPauseEnabled => _autoPauseEnabled;
  int get todayTotalSteps => _todayTotalSteps;
  String? get nextRunTime => _nextRunTime;

  AppLocalizations? _l10n;

  void setL10n(AppLocalizations l10n) {
    if (_l10n == null) {
      _l10n = l10n;
      if (_statusLog.isEmpty) {
        _statusLog = _l10n!.status_ready_to_start;
        notifyListeners();
      }
      _service.invoke('get_status');
    }
  }

  HomePageViewModel() {
    LogService().attachToBackgroundService();
    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    // Unregister lifecycle observer to prevent memory leak
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Trigger step refresh when returning to the app
    if (state == AppLifecycleState.resumed) {
      refreshTodaySteps();
    }
  }

  Future<void> _initialize() async {
    // 1. Setup listeners to catch any events from the service.
    _setupServiceListeners();

    // 2. Ensure the background service is running.
    final isServiceRunning = await _service.isRunning();
    if (!isServiceRunning) {
      await _service.startService();
    }

    // 3. Load user settings from SharedPreferences.
    await _loadNonStateSettings();

    // 4. Get the current step count from the health service.
    await refreshTodaySteps();

    // 5. Now that the service is running and listeners are attached,
    //    request the initial state from the service.
    _service.invoke('get_status');
  }

  // ... (previous methods remain the same)
  void notifyAppDetached() {
    _service.invoke("app_detached");
  }

  void _setupServiceListeners() {
    _service.on('update_ui').listen((event) async {
      if (event == null) return;

      final source = event['source'] as String?;

      _isAutoRunning = event['is_running'] as bool? ?? _isAutoRunning;
      _sessionTotalSteps =
          (event['session_total_steps'] as num?)?.toInt() ?? _sessionTotalSteps;

      if (source != 'manual') {
        _lastStepsWritten =
            (event['last_steps_written'] as num?)?.toInt() ?? _lastStepsWritten;
      }
      
      _nextRunTime = event['next_run_time'] as String?;

      if (_l10n != null) {
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
    _autoPauseThreshold = prefs.getInt(prefAutoPauseThreshold) ?? 5000;
    _offsetEnabled = prefs.getBool(prefOffsetEnabled) ?? true;
    _offsetSteps = prefs.getInt(prefOffsetSteps) ?? 50;

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

  Future<void> refreshTodaySteps() async {
    _todayTotalSteps = await HealthService().getStepsToday();
    notifyListeners();
  }

  Future<bool> _validateParameters() async {
    if (_l10n == null) return true;
    await _loadNonStateSettings();
    final int? base = int.tryParse(_baseSteps);
    if (base == null) return false;
    if (_offsetEnabled && base <= _offsetSteps) {
      Fluttertoast.showToast(msg: _l10n!.error_base_less_than_offset);
      return false;
    }
    if (_autoPauseEnabled) {
      final int maxPossibleWrite = _offsetEnabled ? base + _offsetSteps : base;
      if (_autoPauseThreshold <= maxPossibleWrite) {
        Fluttertoast.showToast(msg: _l10n!.error_threshold_too_low);
        return false;
      }
    }
    return true;
  }

  Future<void> _updateRemainingSteps() async {
    final prefs = await SharedPreferences.getInstance();
    final autoPauseSteps = prefs.getInt(prefAutoPauseThreshold) ?? 5000;
    _remainingSteps = autoPauseSteps - _sessionTotalSteps;
    if (_remainingSteps < 0) _remainingSteps = 0;
  }

  Future<void> reloadSettings() async {
    await _loadNonStateSettings();
    await refreshTodaySteps();
  }

  Future<void> saveBaseSteps(String value) async {
    _baseSteps = value;
    final intValue = int.tryParse(value);
    if (intValue != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(prefBaseSteps, intValue);
      updateSettingsInService();
    }
    notifyListeners();
  }

  Future<void> saveInterval(String value) async {
    _interval = value;
    final intValue = int.tryParse(value);
    if (intValue != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(prefInterval, intValue);
      updateSettingsInService();
    }
    notifyListeners();
  }

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
    final serviceAlive = await _service.isRunning();
    if (!_isAutoRunning) {
      if (!(await _validateParameters())) return;
      if (!serviceAlive) {
        await _service.startService();
      }
       if (_l10n == null) return;
      _service.invoke('start', _getLocalizedStrings());
      Fluttertoast.showToast(msg: _l10n!.auto_service_started);
    } else {
       if (_l10n == null) return;
      _service.invoke("stop", _getLocalizedStrings());
      Fluttertoast.showToast(msg: _l10n!.auto_service_stopped);
      // Ensure data is refreshed immediately after stopping
      await refreshTodaySteps();
    }
  }

  void manualWriteSteps() {
    _service.invoke('write_now', {
      ..._getLocalizedStrings(),
      'source': 'manual',
    });
  }
}
