import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LogService {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;
  LogService._internal();

  static const _logKey = 'activity_log';

  Future<void> addLog(Map<String, dynamic> logEntry) async {
    final prefs = await SharedPreferences.getInstance();
    final log = await getLogs();

    // Add a timestamp to the log entry
    logEntry['timestamp'] = DateTime.now().toIso8601String();

    log.insert(0, logEntry); // Add to the beginning of the list

    // Keep the log size manageable, e.g., 100 entries
    if (log.length > 100) {
      log.removeLast();
    }

    await prefs.setString(_logKey, jsonEncode(log));
  }

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

  Future<void> clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_logKey);
  }
}
