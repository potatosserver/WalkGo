import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String prefLogs = "write_logs";

class LogService {
  Future<void> addLog(Map<String, dynamic> logData) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = prefs.getStringList(prefLogs) ?? [];
    
    // Add a timestamp to ensure every log is unique and sortable
    logData['timestamp'] = DateTime.now().toIso8601String();

    logs.insert(0, jsonEncode(logData)); // Encode map to JSON string and add to top
    await prefs.setStringList(prefLogs, logs);
  }

  Future<List<Map<String, dynamic>>> getLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logStrings = prefs.getStringList(prefLogs) ?? [];
    return logStrings
        .map((logString) => jsonDecode(logString) as Map<String, dynamic>)
        .toList();
  }

  Future<void> clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefLogs);
  }
}
