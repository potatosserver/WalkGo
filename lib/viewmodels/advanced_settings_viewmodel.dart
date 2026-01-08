import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/constants.dart';

class AdvancedSettingsViewModel extends ChangeNotifier {
  bool _offsetEnabled = true;
  String _offsetSteps = "50";
  String _manualSteps = "1000";
  bool _autoPauseEnabled = true;
  String _autoPauseThreshold = "50000";

  bool get offsetEnabled => _offsetEnabled;
  String get offsetSteps => _offsetSteps;
  String get manualSteps => _manualSteps;
  bool get autoPauseEnabled => _autoPauseEnabled;
  String get autoPauseThreshold => _autoPauseThreshold;

  AdvancedSettingsViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _offsetEnabled = prefs.getBool(prefOffsetEnabled) ?? true;
    _offsetSteps = (prefs.getInt(prefOffsetSteps) ?? 50).toString();
    _manualSteps = (prefs.getInt(prefManualSteps) ?? 1000).toString();
    _autoPauseEnabled = prefs.getBool(prefAutoPauseEnabled) ?? true;
    _autoPauseThreshold = (prefs.getInt(prefAutoPauseThreshold) ?? 50000).toString();
    notifyListeners();
  }

  Future<void> setOffsetEnabled(bool value) async {
    _offsetEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefOffsetEnabled, value);
    notifyListeners();
  }

  Future<void> saveOffsetSteps(String value) async {
    _offsetSteps = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefOffsetSteps, int.tryParse(value) ?? 50);
    notifyListeners();
  }

  Future<void> saveManualSteps(String value) async {
    _manualSteps = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefManualSteps, int.tryParse(value) ?? 1000);
    notifyListeners();
  }

  Future<void> setAutoPauseEnabled(bool value) async {
    _autoPauseEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefAutoPauseEnabled, value);
    notifyListeners();
  }

  Future<void> saveAutoPauseThreshold(String value) async {
    _autoPauseThreshold = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefAutoPauseThreshold, int.tryParse(value) ?? 50000);
    notifyListeners();
  }
}
