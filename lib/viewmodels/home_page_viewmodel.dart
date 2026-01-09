import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/constants.dart';
import 'package:walkgo/l10n/app_localizations.dart';

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
      Future.delayed(Duration.zero, () => _updateStatus(isRunning: _isAutoRunning));
    }
  }

  HomePageViewModel() {
    _loadSettings();
    _setupServiceListeners();
    _service.isRunning().then((running) {
      _updateStatus(isRunning: running);
    });
  }

  void _setupServiceListeners() {
    _service.on('update_ui').listen((event) async {
      if (event == null || _l10n == null) return;

      final prefs = await SharedPreferences.getInstance();
      final autoPauseSteps = prefs.getInt(prefAutoPauseThreshold) ?? 50000;

      _isAutoRunning = event['is_running'] as bool? ?? _isAutoRunning;
      _nextRunTime = event['next_run_time'] as String?;
      _lastStepsWritten = (event['last_steps_written'] as num?)?.toInt() ?? 0;

      if (_isAutoRunning) {
        _sessionTotalSteps = (event['session_total_steps'] as num?)?.toInt() ?? 0;
        _statusLog = _l10n!.status_running;
      } else {
        _sessionTotalSteps = 0;
        _lastStepsWritten = 0;
        _nextRunTime = null;
        _statusLog = _l10n!.status_ready_to_start;
      }

      _remainingSteps = autoPauseSteps - _sessionTotalSteps;
      if (_remainingSteps < 0) _remainingSteps = 0;
      
      notifyListeners();
    });

    _service.on('settings_updated').listen((event) {
      reloadSettings();
    });
  }


  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _baseSteps = (prefs.getInt(prefBaseSteps) ?? 500).toString();
    _interval = (prefs.getInt(prefInterval) ?? 1).toString();
    _autoPauseEnabled = prefs.getBool(prefAutoPauseEnabled) ?? false;
    _nextRunTime = prefs.getString(prefNextRunTime);

    final autoPauseSteps = prefs.getInt(prefAutoPauseThreshold) ?? 50000;
    _remainingSteps = autoPauseSteps - _sessionTotalSteps;
    if (_remainingSteps < 0) _remainingSteps = 0;

    notifyListeners();
  }

  Future<void> reloadSettings() async {
    await _loadSettings();
  }

  Future<void> saveBaseSteps(String value) async {
    _baseSteps = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefBaseSteps, int.tryParse(value) ?? 500);
    _service.invoke('update');
    notifyListeners();
  }

  Future<void> saveInterval(String value) async {
    _interval = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefInterval, int.tryParse(value) ?? 1);
    _service.invoke('update');
    notifyListeners();
  }

  Future<void> _updateStatus({required bool isRunning}) async {
    if (_l10n == null) return;

    _isAutoRunning = isRunning;

    if (isRunning) {
      final prefs = await SharedPreferences.getInstance();
      _nextRunTime = prefs.getString(prefNextRunTime);
      _statusLog = _l10n!.status_running;
    } else {
      _statusLog = _l10n!.status_ready_to_start;
      _sessionTotalSteps = 0;
      _lastStepsWritten = 0;
      _nextRunTime = null;
    }
    
    notifyListeners();
  }

  Map<String, String> _getLocalizedStrings() {
    if (_l10n == null) return {};
    return {
      'notification_service_running': _l10n!.notification_service_running,
      'notification_steps_written_title': _l10n!.notification_steps_written_title,
      'notification_steps_written': _l10n!.notification_steps_written('{steps}'),
      'notification_next_run': _l10n!.notification_next_run('{time}'),
      'automatic_write_success': _l10n!.automatic_write_success('{steps}'),
      'write_fail_check_log': _l10n!.write_fail_check_log,
      'notification_service_stopped_title': _l10n!.notification_service_stopped_title,
      'notification_service_stopped_content': _l10n!.notification_service_stopped_content,
      'background_service_start': _l10n!.background_service_start,
      'auto_pause_notification_title': _l10n!.auto_pause_notification_title,
      'auto_pause_notification_content_with_steps': _l10n!.auto_pause_notification_content_with_steps('{steps}'),
      'manual_write_initiated': _l10n!.manual_write_initiated,
    };
  }

  Future<void> updateLocalization() async {
    _service.invoke('update_localization', _getLocalizedStrings());
  }

  Future<void> toggleAutoMode() async {
    if (_l10n == null) return;

    final wantsToRun = !_isAutoRunning;
    
    if (wantsToRun) {
       final isCurrentlyRunning = await _service.isRunning();
      if (!isCurrentlyRunning) {
        await _service.startService();
      }
      _service.invoke('start', _getLocalizedStrings());
    } else {
      _service.invoke("stop", _getLocalizedStrings());
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
