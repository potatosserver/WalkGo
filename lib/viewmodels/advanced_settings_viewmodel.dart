import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/constants.dart';
import 'package:walkgo/viewmodels/home_page_viewmodel.dart';

class AdvancedSettingsViewModel extends ChangeNotifier {
  // Dependency on HomePageViewModel
  final HomePageViewModel _homePageViewModel;

  bool _offsetEnabled = true;
  String _offsetSteps = "50";
  String _manualSteps = "1000";
  bool _autoPauseEnabled = false;
  String _autoPauseThreshold = "5000";

  // Getter directly reflects the state from the HomePageViewModel
  bool get isAutoModeRunning => _homePageViewModel.isAutoRunning;

  bool get offsetEnabled => _offsetEnabled;
  String get offsetSteps => _offsetSteps;
  String get manualSteps => _manualSteps;
  bool get autoPauseEnabled => _autoPauseEnabled;
  String get autoPauseThreshold => _autoPauseThreshold;

  AdvancedSettingsViewModel(this._homePageViewModel) {
    _loadSettings();
    // Listen to changes in the HomePageViewModel
    _homePageViewModel.addListener(_onHomePageViewModelChanged);
  }

  void _log(String message, {bool includeStack = false}) {
		DebugLogService().log(message, includeStack: includeStack);

  // When HomePageViewModel notifies its listeners, this method will be called.
  void _onHomePageViewModelChanged() {
    _log('_onHomePageViewModelChanged called');
    // The only thing we care about is the running state, which might affect the UI lock.
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up the listener when this ViewModel is disposed.
    _homePageViewModel.removeListener(_onHomePageViewModelChanged);
    super.dispose();
  }

  Future<void> _loadSettings() async {
    _log('_loadSettings started');
    final prefs = await SharedPreferences.getInstance();
    _offsetEnabled = prefs.getBool(prefOffsetEnabled) ?? true;
    _offsetSteps = (prefs.getInt(prefOffsetSteps) ?? 50).toString();
    _manualSteps = (prefs.getInt(prefManualSteps) ?? 1000).toString();
    _autoPauseEnabled = prefs.getBool(prefAutoPauseEnabled) ?? false;
    _autoPauseThreshold =
        (prefs.getInt(prefAutoPauseThreshold) ?? 5000).toString();
    _log('_loadSettings completed');
    notifyListeners();
  }

  Future<void> _saveAndNotify() async {
    // No longer needs to invoke service directly.
    // Settings changes are picked up by the background service automatically
    // when it re-reads them from SharedPreferences before each run.
    // We might need a manual trigger if settings need to apply instantly.
    _homePageViewModel
        .reloadSettings(); // Trigger a reload on the home page as well
  }

  Future<void> setOffsetEnabled(bool value) async {
    _log('setOffsetEnabled: $_offsetEnabled -> $value', includeStack: true);
    _offsetEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefOffsetEnabled, value);
    _log('notifyListeners()');
    notifyListeners();
    await _saveAndNotify();
  }

  Future<void> saveOffsetSteps(String value) async {
    _log('saveOffsetSteps: $_offsetSteps -> $value', includeStack: true);
    _offsetSteps = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefOffsetSteps, int.tryParse(value) ?? 50);
    _log('notifyListeners()');
    notifyListeners();
    await _homePageViewModel.reloadSettings();
    _homePageViewModel.updateSettingsInService();
  }

  Future<void> saveManualSteps(String value) async {
    _log('saveManualSteps: $_manualSteps -> $value', includeStack: true);
    _manualSteps = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefManualSteps, int.tryParse(value) ?? 1000);
    _log('notifyListeners()');
    notifyListeners();
    await _homePageViewModel.reloadSettings();
    _homePageViewModel.updateSettingsInService();
  }

  Future<void> setAutoPauseEnabled(bool value) async {
    _log('setAutoPauseEnabled: $_autoPauseEnabled -> $value', includeStack: true);
    _autoPauseEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefAutoPauseEnabled, value);
    _log('notifyListeners()');
    notifyListeners();
    await _homePageViewModel.reloadSettings();
    _homePageViewModel.updateSettingsInService();
  }

  Future<void> saveAutoPauseThreshold(String value) async {
    _log('saveAutoPauseThreshold: $_autoPauseThreshold -> $value', includeStack: true);
    _autoPauseThreshold = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefAutoPauseThreshold, int.tryParse(value) ?? 5000);
    _log('notifyListeners()');
    notifyListeners();
    await _homePageViewModel.reloadSettings();
    _homePageViewModel.updateSettingsInService();
  }
}
