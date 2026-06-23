import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ErrorLogService {
  static final ErrorLogService _instance = ErrorLogService._internal();
  factory ErrorLogService() => _instance;
  ErrorLogService._internal();

  static const _errorLogKey = 'error_log';

  Future<void> addErrorLog(String event, String error) async {
    final prefs = await SharedPreferences.getInstance();
    final log = await getErrorLogs();

    final logEntry = {
      'event': event,
      'error': error,
      'timestamp': DateTime.now().toIso8601String(),
    };

    log.insert(0, logEntry);

    // Keep the log size manageable
    if (log.length > 50) {
      log.removeLast();
    }

    await prefs.setString(_errorLogKey, jsonEncode(log));
  }

  Future<List<Map<String, dynamic>>> getErrorLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logString = prefs.getString(_errorLogKey);
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

  Future<void> clearErrorLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_errorLogKey);
  }
}
