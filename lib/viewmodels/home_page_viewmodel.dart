import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/constants.dart';
import 'package:intl/intl.dart';
import 'package:walkgo/l10n/app_localizations.dart';

class HomePageViewModel extends ChangeNotifier {
  final FlutterBackgroundService _service = FlutterBackgroundService();

  bool _isAutoRunning = false;
  String _statusLog = "";
  int _sessionTotalSteps = 0;
  int _remainingSteps = 0;
  String _baseSteps = "500";
  String _interval = "1";
  bool _autoPauseEnabled = false;

  bool get isAutoRunning => _isAutoRunning;
  String get statusLog => _statusLog;
  int get sessionTotalSteps => _sessionTotalSteps;
  int get remainingSteps => _remainingSteps;
  String get baseSteps => _baseSteps;
  String get interval => _interval;
  bool get autoPauseEnabled => _autoPauseEnabled;

  AppLocalizations? _l10n;

  void setL10n(AppLocalizations l10n) {
    _l10n = l10n;
    if (_statusLog.isEmpty) {
      _updateStatusLogFromPrefs();
    }
  }

  HomePageViewModel() {
    _loadSettings();
    _setupServiceListeners();
    // Check initial running state
    _service.isRunning().then((running) {
      _isAutoRunning = running;
      _updateStatusLogFromPrefs();
      notifyListeners();
    });
  }

  void _setupServiceListeners() {
    _service.on('update_ui').listen((event) async {
      if (event == null || _l10n == null) return;

      final prefs = await SharedPreferences.getInstance();
      final autoPauseSteps = prefs.getInt(prefAutoPauseThreshold) ?? 50000;

      _isAutoRunning = event['is_running'] as bool? ?? _isAutoRunning;
      final newStatusLog = event['status_log'] as String?;

      if (_isAutoRunning) {
        // If service is running, update steps and status log from service
        _sessionTotalSteps = (event['session_total_steps'] as num?)?.toInt() ?? 0;
        if (newStatusLog != null) {
          _statusLog = newStatusLog;
        }
      } else {
        // If service is not running, reset steps and show ready status
        _sessionTotalSteps = 0;
        if (newStatusLog != null && newStatusLog.isNotEmpty) {
           _statusLog = newStatusLog;
        } else {
          _statusLog = _l10n!.status_ready_to_start;
        }
      }

      // Always recalculate remaining steps
      _remainingSteps = autoPauseSteps - _sessionTotalSteps;
      if (_remainingSteps < 0) _remainingSteps = 0;
      
      notifyListeners();
    });
  }


  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _baseSteps = (prefs.getInt(prefBaseSteps) ?? 500).toString();
    _interval = (prefs.getInt(prefInterval) ?? 1).toString();
    _autoPauseEnabled = prefs.getBool(prefAutoPauseEnabled) ?? false;
    await _updateStatusLogFromPrefs();
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

  Future<void> _updateStatusLogFromPrefs() async {
    if (_l10n == null) return;
    final prefs = await SharedPreferences.getInstance();
    final isRunning = prefs.getBool(prefIsAuto) ?? false;
    String statusText;
    if (isRunning) {
      final nextRunTimestamp = prefs.getInt(prefNextRunTime);
      if (nextRunTimestamp != null) {
        final nextRun = DateTime.fromMillisecondsSinceEpoch(nextRunTimestamp);
        final formattedTime = DateFormat('HH:mm').format(nextRun);
        statusText = _l10n!.next_run_at(formattedTime);
      } else {
        statusText = _l10n!.status_running;
      }
    } else {
      statusText = _l10n!.status_ready_to_start;
    }
    _statusLog = statusText;
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
    };
  }

  Future<void> updateLocalization() async {
    _service.invoke('update_localization', _getLocalizedStrings());
  }

  Future<void> toggleAutoMode() async {
    if (_l10n == null) return;

    final wantsToRun = !_isAutoRunning;
    
    // Send command to service, DO NOT change UI state here.
    if (wantsToRun) {
       final isCurrentlyRunning = await _service.isRunning();
      if (!isCurrentlyRunning) {
        await _service.startService();
      }
      _service.invoke('start', _getLocalizedStrings());
      _service.invoke('write_now', _getLocalizedStrings());
    } else {
      _service.invoke("stop", _getLocalizedStrings());
    }
  }

  void manualWriteSteps() {
    if (_l10n == null) return;
    _service.invoke('write_now', _getLocalizedStrings());
  }
}
