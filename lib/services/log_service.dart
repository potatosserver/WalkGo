import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/constants.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class LogService extends ChangeNotifier {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;

  LogService._internal() {
    // Load logs initially when the service is created.
    _loadLogs();
  }

  /// Attaches a listener to the background service to reload logs when they are updated.
  /// This must ONLY be called from the main UI isolate.
  void attachToBackgroundService() {
    try {
      final service = FlutterBackgroundService();
      service.on('log_updated').listen((event) {
        // When a log is updated in the background, reload logs from storage
        // and notify listeners.
        _loadLogs();
      });
    } catch (e) {
      if (kDebugMode) {
        print(
          'LogService: Failed to attach to background service. This is expected if in a secondary isolate.',
        );
      }
    }
  }

  static const _logKey = 'activity_log';
  List<Map<String, dynamic>> _logs = [];

  // Synchronous getter for the UI.
  List<Map<String, dynamic>> get logs => _logs;

  // Load logs from SharedPreferences into the in-memory list.
  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    // Force a reload from disk to get the latest data written by another isolate.
    await prefs.reload();

    final logString = prefs.getString(_logKey);
    if (logString != null && logString.isNotEmpty) {
      try {
        final decoded = jsonDecode(logString);
        if (decoded is List) {
          _logs = decoded.cast<Map<String, dynamic>>().toList();
        }
      } catch (e) {
        _logs = [];
      }
    } else {
      _logs = [];
    }
    // Notify listeners after loading, so UI can update if it was waiting.
    notifyListeners();
  }

  // Instance method for adding a log from the UI/foreground.
  // Note: For WalkGo, manual writes are usually handled by invoking the background service's 'write_now'.
  // This method remains for general-purpose foreground logging if needed.
  Future<void> addLog(int steps, {String source = 'manual'}) async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();

    if (isRunning) {
      // If service is running, we should NOT write directly to SharedPreferences
      // because we'll likely race with the background isolate.
      // Instead, we tell the background service to do a manual write.
      // (The BackgroundService's 'write_now' handler will call writeLogFromBackground)
      service.invoke('write_now', {'source': source});
    } else {
      // Service is not running, we are the only isolate, safe to write.
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();

      final logString = prefs.getString(_logKey);
      List<dynamic> logList = [];
      if (logString != null && logString.isNotEmpty) {
        try {
          logList = jsonDecode(logString);
        } catch (e) {
          logList = [];
        }
      }

      final logEntry = {
        'steps': steps,
        'timestamp': DateTime.now().toIso8601String(),
        'source': source,
      };

      logList.insert(0, logEntry);
      if (logList.length > 100) {
        logList.removeLast();
      }

      await prefs.setString(_logKey, jsonEncode(logList));
      _logs = logList.cast<Map<String, dynamic>>().toList();
      notifyListeners();
    }
  }

  Future<void> clearLogs() async {
    // Clear in-memory list
    _logs = [];
    // Notify UI
    notifyListeners();

    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_logKey);
    await prefs.setInt(prefSessionTotalSteps, 0);

    // Also notify background if it's running
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke('get_status'); // Force a refresh
    }
  }

  Future<void> resetLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefSessionTotalSteps, 0);

    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke('get_status');
    }

    notifyListeners();
  }
}
