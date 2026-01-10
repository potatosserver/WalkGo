import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/constants.dart';

class AdvancedSettingsViewModel extends ChangeNotifier {
  final _service = FlutterBackgroundService();
  
  bool _isAutoModeRunning = false;
  bool _offsetEnabled = true;
  String _offsetSteps = "50";
  String _manualSteps = "1000";
  bool _autoPauseEnabled = false;
  String _autoPauseThreshold = "50000";

  bool get isAutoModeRunning => _isAutoModeRunning;
  bool get offsetEnabled => _offsetEnabled;
  String get offsetSteps => _offsetSteps;
  String get manualSteps => _manualSteps;
  bool get autoPauseEnabled => _autoPauseEnabled;
  String get autoPauseThreshold => _autoPauseThreshold;

  AdvancedSettingsViewModel() {
    _loadSettings();
    // Listen for the global running state from the service
    _service.on('update_ui').listen((event) {
      final isRunning = event?['is_running'] as bool?;
      if (isRunning != null && _isAutoModeRunning != isRunning) {
        _isAutoModeRunning = isRunning;
        notifyListeners();
      }
    });
    _checkInitialRunningState();
  }

  Future<void> _checkInitialRunningState() async {
    final prefs = await SharedPreferences.getInstance();
    final isRunning = prefs.getBool(prefIsAuto) ?? false;
     if (_isAutoModeRunning != isRunning) {
        _isAutoModeRunning = isRunning;
        notifyListeners();
      }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _offsetEnabled = prefs.getBool(prefOffsetEnabled) ?? true;
    _offsetSteps = (prefs.getInt(prefOffsetSteps) ?? 50).toString();
    _manualSteps = (prefs.getInt(prefManualSteps) ?? 1000).toString();
    _autoPauseEnabled = prefs.getBool(prefAutoPauseEnabled) ?? false;
    _autoPauseThreshold = (prefs.getInt(prefAutoPauseThreshold) ?? 50000).toString();
    notifyListeners();
  }

  Future<void> _saveAndNotify() async {
    _service.invoke('update');
  }

  Future<void> setOffsetEnabled(bool value) async {
    _offsetEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefOffsetEnabled, value);
    notifyListeners();
    await _saveAndNotify();
  }

  Future<void> saveOffsetSteps(String value) async {
    _offsetSteps = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefOffsetSteps, int.tryParse(value) ?? 50);
    notifyListeners();
    await _saveAndNotify();
  }

  Future<void> saveManualSteps(String value) async {
    _manualSteps = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefManualSteps, int.tryParse(value) ?? 1000);
    notifyListeners();
    await _saveAndNotify();
  }

  Future<void> setAutoPauseEnabled(bool value) async {
    _autoPauseEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefAutoPauseEnabled, value);
    notifyListeners();
    await _saveAndNotify();
  }

  Future<void> saveAutoPauseThreshold(String value) async {
    _autoPauseThreshold = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefAutoPauseThreshold, int.tryParse(value) ?? 50000);
    notifyListeners();
    await _saveAndNotify();
  }
}
