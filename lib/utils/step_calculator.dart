import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/constants.dart';
import 'package:walkgo/health_service.dart';

Future<Map<String, int>> calculateFinalSteps(SharedPreferences prefs) async {
  await prefs.reload();
  final baseSteps = prefs.getInt(prefBaseSteps) ?? 500;
  final offsetEnabled = prefs.getBool(prefOffsetEnabled) ?? true;
  final offset = prefs.getInt(prefOffsetSteps) ?? 50;

  final currentSteps = await HealthService().getStepsToday();
  int stepsToAdd = baseSteps;

  if (offsetEnabled && offset > 0) {
    final randomJitter = Random().nextInt(offset * 2 + 1) - offset;
    stepsToAdd = baseSteps + randomJitter;
    if (stepsToAdd < 1) {
      stepsToAdd = 1;
    }
  }

  final totalStepsToWrite = currentSteps + stepsToAdd;

  return {
    'totalStepsToWrite': totalStepsToWrite,
    'originalSteps': currentSteps,
    'stepsAdded': stepsToAdd,
  };
}
