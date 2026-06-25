import 'package:flutter/material.dart';

class DebugLogService {
  static final DebugLogService _instance = DebugLogService._internal();
  factory DebugLogService() => _instance;
  DebugLogService._internal();

  final List<String> _logs = [];
  final ValueNotifier<List<String>> logsNotifier = ValueNotifier([]);

  void log(String message, {bool includeStack = false}) {
    final timestamp = DateTime.now().toIso8601String().split('T').last.substring(0, 12);
    final logEntry = "[$timestamp] $message${includeStack ? '\n${StackTrace.current}' : ''}";
    
    _logs.add(logEntry);
    if (_logs.length > 1000) {
      _logs.removeAt(0);
    }
    
    // Trigger UI update
    logsNotifier.value = List.from(_logs);
    
    // Still print to console for those who have ADB
    debugPrint(logEntry);
  }

  void clear() {
    _logs.clear();
    logsNotifier.value = [];
  }

  List<String> get allLogs => List.from(_logs);
}
