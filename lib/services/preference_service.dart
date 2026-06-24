import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static final PreferenceService _instance = PreferenceService._internal();
  factory PreferenceService() => _instance;
  PreferenceService._internal();

  static const String _keySkipNotification = 'skip_notification_permission';
  static const String _keySkipBattery = 'skip_battery_permission';

  Future<void> setSkipNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySkipNotification, value);
  }

  Future<bool> getSkipNotification() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySkipNotification) ?? false;
  }

  Future<void> setSkipBattery(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySkipBattery, value);
  }

  Future<bool> getSkipBattery() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySkipBattery) ?? false;
  }

  Future<void> clearSkipPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySkipNotification);
    await prefs.remove(_keySkipBattery);
  }
}
