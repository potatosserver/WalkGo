
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/constants.dart';

class LogService {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;
  LogService._internal();

  static const _logKey = 'activity_log';

  Future<int> addLog(int steps) async {
    final prefs = await SharedPreferences.getInstance();
    final log = await getLogs();

    final logEntry = {
      'steps': steps,
      'timestamp': DateTime.now().toIso8601String(),
    };

    log.insert(0, logEntry); // Add to the beginning of the list

    // Keep the log size manageable, e.g., 100 entries
    if (log.length > 100) {
      log.removeLast();
    }

    await prefs.setString(_logKey, jsonEncode(log));

    // Update and return the session total
    final currentTotal = prefs.getInt(prefSessionTotalSteps) ?? 0;
    final newTotal = currentTotal + steps;
    await prefs.setInt(prefSessionTotalSteps, newTotal);
    return newTotal;
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
    // Also reset the session total when clearing logs
    await prefs.setInt(prefSessionTotalSteps, 0);
  }
}
