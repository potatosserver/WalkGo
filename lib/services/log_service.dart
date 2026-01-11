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

    // Listen for events from the background service.
    final service = FlutterBackgroundService();
    service.on('log_updated').listen((event) {
      // When a log is updated in the background, reload logs from storage
      // and notify listeners.
      _loadLogs();
    });
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

  // A static method that can be called from a background isolate.
  // This is a "fire-and-forget" write operation.
  // It returns the new total steps for the background service to keep track of.
  static Future<int> writeLogFromBackground(int steps, {String source = 'automatic'}) async {
    final prefs = await SharedPreferences.getInstance();
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

    // Also update session total steps
    final currentTotal = prefs.getInt(prefSessionTotalSteps) ?? 0;
    final newTotal = currentTotal + steps;
    await prefs.setInt(prefSessionTotalSteps, newTotal);
    
    // The background service will call service.invoke('log_updated') after this.
    return newTotal;
  }

  // Instance method for adding a log from the UI/foreground.
  Future<void> addLog(int steps, {String source = 'manual'}) async {
    final logEntry = {
      'steps': steps,
      'timestamp': DateTime.now().toIso8601String(),
      'source': source,
    };

    // Update in-memory list immediately
    _logs.insert(0, logEntry);
    if (_logs.length > 100) {
      _logs.removeLast();
    }
    
    // Notify UI to rebuild
    notifyListeners();

    // Persist changes to SharedPreferences asynchronously
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_logKey, jsonEncode(_logs));

    // Also update session total steps
    final currentTotal = prefs.getInt(prefSessionTotalSteps) ?? 0;
    final newTotal = currentTotal + steps;
    await prefs.setInt(prefSessionTotalSteps, newTotal);
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
  }
  
  Future<void> resetLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefSessionTotalSteps, 0);
    notifyListeners();
  }
}