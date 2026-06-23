import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LogUtils {
  static const String _logKey = 'activity_log';

  /// A static method that can be called from a background isolate.
  /// It writes a log entry to SharedPreferences without any UI dependencies.
  static Future<void> writeLogFromBackground(
    int steps, {
    String source = 'automatic',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // Critical: reload before reading in background

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
  }
}
