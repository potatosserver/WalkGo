import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/constants.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class LogService extends ChangeNotifier {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;

  LogService._internal() {
    // Listen for the 'log_updated' event from the background service.
    final service = FlutterBackgroundService();
    service.on('log_updated').listen((event) {
      // When the log is updated in the background, just notify the UI to refresh.
      notifyListeners();
    });
  }

  static const _logKey = 'activity_log';

  // This static method can be called from anywhere, including the background isolate.
  // It handles the logic of writing a log entry to SharedPreferences.
  static Future<int> writeLogToStorage(int steps, {String source = 'manual'}) async {
    final prefs = await SharedPreferences.getInstance();
    final logString = prefs.getString(_logKey);
    List<dynamic> log = [];
    if (logString != null && logString.isNotEmpty) {
      try {
        log = jsonDecode(logString);
      } catch (e) {
        // Handle potential decoding errors
        log = [];
      }
    }

    final logEntry = {
      'steps': steps,
      'timestamp': DateTime.now().toIso8601String(),
      'source': source,
    };

    log.insert(0, logEntry);

    if (log.length > 100) {
      log.removeLast();
    }

    await prefs.setString(_logKey, jsonEncode(log));

    final currentTotal = prefs.getInt(prefSessionTotalSteps) ?? 0;
    final newTotal = currentTotal + steps;
    await prefs.setInt(prefSessionTotalSteps, newTotal);
    return newTotal;
  }

  // This method remains part of the ChangeNotifier for the UI to use.
  Future<List<Map<String, dynamic>>> getLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logString = prefs.getString(_logKey);
    if (logString == null || logString.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(logString);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>().toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // This method also remains for UI interaction.
  Future<void> clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_logKey);
    await prefs.setInt(prefSessionTotalSteps, 0);
    notifyListeners();
  }

  Future<void> resetLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefSessionTotalSteps, 0);
    notifyListeners();
  }
}
